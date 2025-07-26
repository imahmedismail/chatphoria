# Chatphoria 💬

A beautiful, real-time chat application built with Phoenix LiveView and Tailwind CSS.

![Phoenix](https://img.shields.io/badge/Phoenix-1.7-orange.svg)
![Elixir](https://img.shields.io/badge/Elixir-1.14+-purple.svg)
![LiveView](https://img.shields.io/badge/LiveView-Real--time-green.svg)
![Tailwind](https://img.shields.io/badge/Tailwind-CSS-blue.svg)

## ✨ Features

- **Real-time messaging** - Instant message delivery using Phoenix PubSub
- **Beautiful UI** - Modern, responsive design with Tailwind CSS gradients and animations
- **Room management** - Create, join, and switch between chat rooms
- **Typing indicators** - See when other users are typing in real-time
- **User presence** - Online status tracking for all users
- **Simple authentication** - Username/email registration system
- **Message history** - Persistent chat history with timestamps
- **Responsive design** - Works seamlessly on desktop and mobile

## 🚀 Quick Start

### Prerequisites

- Elixir 1.14 or later
- Erlang/OTP 25 or later
- PostgreSQL database

### Installation

1. **Clone and setup:**
   ```bash
   git clone <repository-url>
   cd chatphoria
   mix setup
   ```

2. **Start the server:**
   ```bash
   mix phx.server
   ```

3. **Visit the app:**
   Open [localhost:4000](http://localhost:4000) in your browser

### Sample Data

The app comes with pre-seeded data including:
- 3 sample users (alice, bob, charlie)
- 3 chat rooms (General, Random, Tech Talk)
- Welcome messages to get you started

## 🎮 How to Use

1. **Register:** Enter a username and email on the home page
2. **Join rooms:** Click on any room in the sidebar to join the conversation
3. **Create rooms:** Click the "+ New" button to create your own room
4. **Chat:** Type messages and see real-time updates from other users
5. **See activity:** Watch typing indicators and user presence updates

## 🏗️ Architecture

### Database Schema

- **Users** - Authentication and user profiles
- **Rooms** - Chat room management with privacy settings
- **Messages** - Chat messages with timestamps and user associations
- **Room Memberships** - User-room relationships with roles

### Key Components

- **ChatLive** - Main LiveView handling real-time chat functionality
- **UserSessionController** - Simple authentication system
- **Chat Context** - Business logic for rooms and messages
- **Accounts Context** - User management and authentication

### Real-time Features

- **Phoenix PubSub** - Message broadcasting across connected clients
- **LiveView** - Real-time UI updates without JavaScript
- **Typing indicators** - Debounced input events with automatic timeout
- **Presence tracking** - User online/offline status management

## 🎨 UI Design

The application features a modern, professional design with:

- **Gradient backgrounds** - Beautiful blue-to-indigo gradients
- **Card-based layout** - Clean, organized interface components
- **Smooth animations** - Hover effects and transitions
- **Responsive design** - Mobile-first approach with Tailwind CSS
- **Color-coded avatars** - Unique gradient avatars for each user
- **Typography hierarchy** - Clear information organization

## 🔧 Development

### Available Commands

```bash
# Setup project and database
mix setup

# Start development server
mix phx.server

# Run tests
mix test

# Reset database with fresh data
mix ecto.reset

# Build assets
mix assets.build
```

### Project Structure

```
lib/
├── chatphoria/
│   ├── accounts/          # User management
│   └── chat/              # Chat functionality
├── chatphoria_web/
│   ├── controllers/       # Authentication
│   ├── live/              # LiveView components
│   └── components/        # UI components
priv/
└── repo/
    ├── migrations/        # Database schema
    └── seeds.exs          # Sample data
```

## 🚀 Deployment

Ready to run in production? Please check the [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## 🛠️ Built With

- **[Phoenix Framework](https://www.phoenixframework.org/)** - Web framework
- **[Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/)** - Real-time UI
- **[Tailwind CSS](https://tailwindcss.com/)** - Styling and design
- **[PostgreSQL](https://www.postgresql.org/)** - Database
- **[Ecto](https://hexdocs.pm/ecto/)** - Database wrapper

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

---

**Chatphoria** - Where conversations come alive! 🎉
