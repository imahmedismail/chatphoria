defmodule ChatphoriaWeb.ChatLive do
  use ChatphoriaWeb, :live_view

  alias Chatphoria.{Accounts, Chat}

  @impl true
  def mount(_params, %{"user_id" => user_id} = _session, socket) do
    user = Accounts.get_user!(user_id)
    rooms = Chat.list_public_rooms()
    
    # Join default room if no rooms exist
    default_room = case rooms do
      [] ->
        {:ok, room} = Chat.create_room(%{
          name: "General",
          description: "General discussion",
          created_by_id: user_id
        })
        Chat.join_room(user_id, room.id, "owner")
        room
      [room | _] ->
        unless Chat.is_member?(user_id, room.id) do
          Chat.join_room(user_id, room.id)
        end
        room
    end

    messages = Chat.list_messages_for_room(default_room.id)

    # Subscribe to room updates
    if connected?(socket) do
      ChatphoriaWeb.Endpoint.subscribe("room:#{default_room.id}")
      Accounts.update_user_status(user, "online")
    end

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:rooms, rooms)
     |> assign(:current_room, default_room)
     |> assign(:messages, messages)
     |> assign(:new_message, "")
     |> assign(:online_users, Accounts.get_online_users())
     |> assign(:show_create_room, false)
     |> assign(:new_room_name, "")
     |> assign(:new_room_description, "")
     |> assign(:typing_users, [])
     |> assign(:show_sidebar, false)}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: ~p"/")}
  end

  @impl true
  def handle_event("send_message", %{"message" => message_content}, socket) do
    case String.trim(message_content) do
      "" ->
        {:noreply, socket}

      content ->
        case Chat.create_message(%{
               content: content,
               user_id: socket.assigns.user.id,
               room_id: socket.assigns.current_room.id
             }) do
          {:ok, message} ->
            message_with_user = %{message | user: socket.assigns.user}
            
            # Broadcast to all users in the room
            ChatphoriaWeb.Endpoint.broadcast(
              "room:#{socket.assigns.current_room.id}",
              "new_message",
              %{message: message_with_user}
            )

            {:noreply, assign(socket, :new_message, "")}

          {:error, _changeset} ->
            {:noreply, put_flash(socket, :error, "Failed to send message")}
        end
    end
  end

  @impl true
  def handle_event("toggle_create_room", _params, socket) do
    {:noreply, assign(socket, :show_create_room, !socket.assigns.show_create_room)}
  end

  @impl true
  def handle_event("toggle_sidebar", _params, socket) do
    {:noreply, assign(socket, :show_sidebar, !socket.assigns.show_sidebar)}
  end

  @impl true
  def handle_event("create_room", %{"room_name" => name, "room_description" => description}, socket) do
    case Chat.create_room(%{
           name: String.trim(name),
           description: String.trim(description),
           created_by_id: socket.assigns.user.id
         }) do
      {:ok, room} ->
        # Join the new room as owner
        Chat.join_room(socket.assigns.user.id, room.id, "owner")
        
        # Update rooms list
        updated_rooms = [room | socket.assigns.rooms]
        
        {:noreply,
         socket
         |> assign(:rooms, updated_rooms)
         |> assign(:show_create_room, false)
         |> assign(:new_room_name, "")
         |> assign(:new_room_description, "")
         |> put_flash(:info, "Room '#{room.name}' created successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create room")}
    end
  end

  @impl true
  def handle_event("typing", %{"value" => message}, socket) do
    if String.trim(message) != "" do
      # Broadcast typing indicator
      ChatphoriaWeb.Endpoint.broadcast(
        "room:#{socket.assigns.current_room.id}",
        "user_typing",
        %{user: socket.assigns.user, typing: true}
      )

      # Schedule stop typing after 2 seconds
      Process.send_after(self(), :stop_typing, 2000)
    end

    {:noreply, assign(socket, :new_message, message)}
  end

  @impl true
  def handle_event("change_room", %{"room_id" => room_id}, socket) do
    room_id = String.to_integer(room_id)
    room = Chat.get_room!(room_id)
    messages = Chat.list_messages_for_room(room_id)

    # Unsubscribe from old room and subscribe to new room
    ChatphoriaWeb.Endpoint.unsubscribe("room:#{socket.assigns.current_room.id}")
    ChatphoriaWeb.Endpoint.subscribe("room:#{room_id}")

    {:noreply,
     socket
     |> assign(:current_room, room)
     |> assign(:messages, messages)
     |> assign(:typing_users, [])
     |> assign(:show_sidebar, false)}
  end

  @impl true
  def handle_info(%{topic: "room:" <> _room_id, event: "new_message", payload: %{message: message}}, socket) do
    updated_messages = socket.assigns.messages ++ [message]
    {:noreply, assign(socket, :messages, updated_messages)}
  end

  @impl true
  def handle_info(%{topic: "room:" <> _room_id, event: "user_typing", payload: %{user: user, typing: true}}, socket) do
    if user.id != socket.assigns.user.id do
      updated_typing = [user | Enum.reject(socket.assigns.typing_users, &(&1.id == user.id))]
      {:noreply, assign(socket, :typing_users, updated_typing)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:stop_typing, socket) do
    ChatphoriaWeb.Endpoint.broadcast(
      "room:#{socket.assigns.current_room.id}",
      "user_typing",
      %{user: socket.assigns.user, typing: false}
    )
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: "room:" <> _room_id, event: "user_typing", payload: %{user: user, typing: false}}, socket) do
    updated_typing = Enum.reject(socket.assigns.typing_users, &(&1.id == user.id))
    {:noreply, assign(socket, :typing_users, updated_typing)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex h-screen bg-gray-100 relative">
      <!-- Mobile overlay -->
      <%= if @show_sidebar do %>
        <div 
          class="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
          phx-click="toggle_sidebar"
        ></div>
      <% end %>

      <!-- Sidebar -->
      <div class={[
        "bg-white shadow-lg flex flex-col transition-transform duration-300 ease-in-out z-50",
        "lg:relative lg:translate-x-0 lg:w-64",
        "fixed inset-y-0 left-0 w-80 max-w-[85vw]",
        if(@show_sidebar, do: "translate-x-0", else: "-translate-x-full lg:translate-x-0")
      ]}>
        <!-- Mobile close button -->
        <div class="lg:hidden p-4 border-b bg-gradient-to-r from-blue-500 to-indigo-600">
          <button
            phx-click="toggle_sidebar"
            class="text-white hover:text-gray-200"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>

        <!-- User info -->
        <div class="p-4 bg-gradient-to-r from-blue-500 to-indigo-600 text-white">
          <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
              <span class="font-semibold text-lg">
                <%= String.first(@user.username) |> String.upcase() %>
              </span>
            </div>
            <div class="min-w-0 flex-1">
              <h3 class="font-semibold truncate"><%= @user.username %></h3>
              <p class="text-blue-100 text-sm">Online</p>
            </div>
          </div>
        </div>

        <!-- Rooms list -->
        <div class="flex-1 overflow-y-auto">
          <div class="p-4">
            <div class="flex items-center justify-between mb-3">
              <h4 class="text-sm font-semibold text-gray-500 uppercase tracking-wide">Rooms</h4>
              <button
                phx-click="toggle_create_room"
                class="text-blue-500 hover:text-blue-700 font-semibold text-sm touch-manipulation"
              >
                + New
              </button>
            </div>

            <%= if @show_create_room do %>
              <div class="mb-4 p-3 bg-gray-50 rounded-lg">
                <form phx-submit="create_room" class="space-y-3">
                  <input
                    type="text"
                    name="room_name"
                    placeholder="Room name"
                    required
                    class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:ring-1 focus:ring-blue-500 touch-manipulation"
                  />
                  <input
                    type="text"
                    name="room_description"
                    placeholder="Description (optional)"
                    class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:ring-1 focus:ring-blue-500 touch-manipulation"
                  />
                  <div class="flex space-x-2">
                    <button
                      type="submit"
                      class="flex-1 bg-blue-500 text-white px-3 py-3 rounded text-sm hover:bg-blue-600 touch-manipulation"
                    >
                      Create
                    </button>
                    <button
                      type="button"
                      phx-click="toggle_create_room"
                      class="flex-1 bg-gray-300 text-gray-700 px-3 py-3 rounded text-sm hover:bg-gray-400 touch-manipulation"
                    >
                      Cancel
                    </button>
                  </div>
                </form>
              </div>
            <% end %>

            <div class="space-y-2">
              <%= for room <- @rooms do %>
                <button
                  phx-click="change_room"
                  phx-value-room_id={room.id}
                  class={[
                    "w-full text-left p-3 rounded-lg transition-colors touch-manipulation",
                    if(@current_room.id == room.id, do: "bg-blue-100 text-blue-700", else: "hover:bg-gray-100 active:bg-gray-200")
                  ]}
                >
                  <div class="flex items-center space-x-2">
                    <span class="text-xl">#</span>
                    <span class="font-medium truncate"><%= room.name %></span>
                  </div>
                  <%= if room.description do %>
                    <p class="text-sm text-gray-500 mt-1 truncate"><%= room.description %></p>
                  <% end %>
                </button>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Logout button -->
        <div class="p-4 border-t">
          <a
            href="/logout"
            class="block w-full text-center py-3 px-4 bg-gray-200 hover:bg-gray-300 active:bg-gray-400 rounded-lg transition-colors text-gray-700 touch-manipulation"
          >
            Logout
          </a>
        </div>
      </div>

      <!-- Main chat area -->
      <div class="flex-1 flex flex-col min-w-0">
        <!-- Chat header -->
        <div class="bg-white shadow-sm p-3 lg:p-4 border-b">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-3 min-w-0 flex-1">
              <!-- Mobile menu button -->
              <button
                phx-click="toggle_sidebar"
                class="lg:hidden p-2 -ml-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded touch-manipulation"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
                </svg>
              </button>
              
              <div class="min-w-0 flex-1">
                <h2 class="text-lg lg:text-xl font-semibold text-gray-900 truncate"># <%= @current_room.name %></h2>
                <%= if @current_room.description do %>
                  <p class="text-gray-600 text-sm truncate hidden sm:block"><%= @current_room.description %></p>
                <% end %>
              </div>
            </div>
            
            <div class="flex items-center space-x-2 flex-shrink-0">
              <span class="inline-flex items-center px-2 lg:px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                <span class="hidden sm:inline"><%= length(@online_users) %> online</span>
                <span class="sm:hidden"><%= length(@online_users) %></span>
              </span>
            </div>
          </div>
        </div>

        <!-- Messages -->
        <div class="flex-1 overflow-y-auto p-3 lg:p-4 space-y-3 lg:space-y-4" id="messages-container">
          <%= for message <- @messages do %>
            <div class="flex space-x-2 lg:space-x-3">
              <div class="w-7 h-7 lg:w-8 lg:h-8 bg-gradient-to-r from-blue-400 to-purple-500 rounded-full flex items-center justify-center text-white font-semibold text-xs lg:text-sm flex-shrink-0">
                <%= String.first(message.user.username) |> String.upcase() %>
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center space-x-2 mb-1">
                  <span class="font-semibold text-gray-900 text-sm lg:text-base truncate"><%= message.user.username %></span>
                  <span class="text-xs text-gray-500 flex-shrink-0">
                    <%= Calendar.strftime(message.inserted_at, "%H:%M") %>
                  </span>
                </div>
                <p class="text-gray-700 leading-relaxed text-sm lg:text-base break-words"><%= message.content %></p>
              </div>
            </div>
          <% end %>

          <!-- Typing indicators -->
          <%= if length(@typing_users) > 0 do %>
            <div class="flex space-x-2 lg:space-x-3 animate-pulse">
              <div class="w-7 h-7 lg:w-8 lg:h-8 bg-gray-300 rounded-full flex items-center justify-center text-gray-600 font-semibold text-xs flex-shrink-0">
                ●●●
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-gray-500 text-sm italic">
                  <%= case length(@typing_users) do %>
                    <% 1 -> %><%= List.first(@typing_users).username %> is typing...
                    <% 2 -> %><%= Enum.map(@typing_users, &(&1.username)) |> Enum.join(" and ") %> are typing...
                    <% n when n > 2 -> %>Several people are typing...
                  <% end %>
                </p>
              </div>
            </div>
          <% end %>
        </div>

        <!-- Message input -->
        <div class="bg-white border-t p-3 lg:p-4">
          <form phx-submit="send_message" class="flex space-x-2 lg:space-x-3">
            <input
              type="text"
              name="message"
              value={@new_message}
              placeholder={"Message ##{@current_room.name}"}
              class="flex-1 px-3 lg:px-4 py-2 lg:py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm lg:text-base touch-manipulation"
              autocomplete="off"
              phx-keyup="typing"
              phx-debounce="300"
            />
            <button
              type="submit"
              class="px-4 lg:px-6 py-2 lg:py-3 bg-gradient-to-r from-blue-500 to-indigo-600 text-white font-semibold rounded-lg hover:from-blue-600 hover:to-indigo-700 active:from-blue-700 active:to-indigo-800 transition-all text-sm lg:text-base touch-manipulation"
            >
              <span class="hidden sm:inline">Send</span>
              <span class="sm:hidden">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"></path>
                </svg>
              </span>
            </button>
          </form>
        </div>
      </div>
    </div>

    <script>
      // Auto-scroll to bottom when new messages arrive
      const messagesContainer = document.getElementById('messages-container');
      if (messagesContainer) {
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
      }

      // Close sidebar when clicking on a room (mobile only)
      if (window.innerWidth < 1024) {
        document.addEventListener('phx:page-loading-stop', () => {
          // This will be handled by the toggle_sidebar event
        });
      }
    </script>
    """
  end
end