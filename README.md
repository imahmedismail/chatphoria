# Chatphoria 💬

A full-featured, real-time chat application built with Phoenix LiveView and Tailwind CSS, featuring both group rooms and WhatsApp-style direct messaging.

![Phoenix](https://img.shields.io/badge/Phoenix-1.7-orange.svg)
![Elixir](https://img.shields.io/badge/Elixir-1.14+-purple.svg)
![LiveView](https://img.shields.io/badge/LiveView-Real--time-green.svg)
![Tailwind](https://img.shields.io/badge/Tailwind-CSS-blue.svg)

## ✨ Features

### 💬 Chat Functionality
- **Real-time messaging** - Instant message delivery using Phoenix PubSub
- **Group chat rooms** - Create, join, and switch between public chat rooms
- **One-to-one messaging** - WhatsApp-style direct messaging with conversation bubbles
- **Dual chat modes** - Switch between group rooms and private conversations
- **Message history** - Persistent chat history with timestamps
- **Typing indicators** - See when other users are typing in real-time

### 🎨 User Interface  
- **WhatsApp-style conversations** - Messages appear on right (you) and left (others)
- **Beautiful UI** - Modern, responsive design with gradient backgrounds
- **Tabbed navigation** - Clean switch between "Rooms" and "Direct" messaging
- **Smart flash messages** - Auto-dismissing notifications with progress bars
- **Mobile responsive** - Collapsible sidebar and touch-optimized interface
- **Color-coded avatars** - Unique gradient avatars for each user

### 👥 User Management
- **User presence** - Online/offline status tracking for all users
- **Simple authentication** - Username/email registration system
- **User discovery** - Browse and start conversations with other users
- **Session management** - Persistent login sessions

### 🔧 Technical Features
- **LiveView hooks** - Clean JavaScript integration for enhanced UX
- **Real-time updates** - Instant UI updates without page refreshes
- **Database constraints** - Robust data validation and relationships
- **Comprehensive testing** - Full test suite for all chat functionality

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

## 🎥 Video Tutorial

### Complete App Walkthrough

Watch this comprehensive demo showcasing all of Chatphoria's features:

https://github.com/user-attachments/assets/videos/project-tutorial.mov

> **What you'll see in this video:**
> - 🔐 User registration and authentication
> - 💬 Group chat rooms vs Direct messaging
> - 🎨 WhatsApp-style conversation interface  
> - 📱 Mobile responsive design
> - ⚡ Real-time messaging and typing indicators
> - 🔔 Smart auto-dismissing notifications
> - 👥 User presence and online status

*Video demonstrates both desktop and mobile experiences*

### Sample Data

The app comes with pre-seeded data including:
- 3 sample users (alice, bob, charlie)
- 3 chat rooms (General, Random, Tech Talk)
- Welcome messages to get you started

## 🎮 How to Use

### Getting Started
1. **Register:** Enter a username and email on the home page
2. **Choose chat mode:** Use the "Rooms" and "Direct" tabs in the sidebar

### Group Chat Rooms
3. **Join rooms:** Click on any room in the sidebar to join the conversation
4. **Create rooms:** Click the "+ New" button next to "Rooms" to create your own room
5. **Room chat:** Messages appear with usernames and avatars in chronological order

### Direct Messaging
6. **Start conversations:** Click the "+ New" button next to "Direct Messages"
7. **Select user:** Choose from the list of available users to start a conversation
8. **WhatsApp-style chat:** Your messages appear on the right (blue), theirs on the left (gray)

### General Features
9. **See activity:** Watch typing indicators and user presence updates
10. **Auto-dismiss notifications:** Success/error messages dismiss automatically with progress bars
11. **Mobile friendly:** Use the hamburger menu on mobile to access the sidebar

## 🏗️ Architecture

### Database Schema

- **Users** - Authentication and user profiles with online status
- **Rooms** - Chat room management with privacy settings and ownership
- **Messages** - Chat messages supporting both room and conversation contexts
- **Room Memberships** - User-room relationships with roles (owner, member)
- **Conversations** - One-to-one chat relationships with message timestamps
- **Database Constraints** - Ensures messages belong to either rooms OR conversations

### Key Components

- **ChatLive** - Main LiveView handling dual chat modes (rooms & conversations)
- **Flash Auto-Dismiss Hook** - JavaScript hook for enhanced flash message UX
- **UserSessionController** - Simple authentication system
- **Chat Context** - Business logic for rooms, messages, and conversations
- **Accounts Context** - User management, authentication, and presence
- **Core Components** - Reusable UI components with custom styling

### Real-time Features

- **Phoenix PubSub** - Message broadcasting for both rooms and conversations
- **LiveView** - Real-time UI updates without page refreshes
- **Typing indicators** - Context-aware indicators for rooms and conversations
- **Presence tracking** - User online/offline status with visual indicators
- **Auto-scrolling** - Messages automatically scroll to bottom on new content
- **State management** - Seamless switching between chat contexts

## 🎨 UI Design

The application features a modern, professional design with:

### Visual Design
- **Gradient backgrounds** - Beautiful blue-to-indigo gradients throughout
- **WhatsApp-style bubbles** - Familiar chat interface for direct messages
- **Smart flash messages** - Auto-dismissing notifications with countdown progress bars
- **Tabbed navigation** - Clean switching between Rooms and Direct messaging
- **Color-coded avatars** - Unique gradient avatars for each user

### User Experience
- **Responsive design** - Mobile-first approach with collapsible sidebar
- **Touch-optimized** - Large tap targets and smooth animations
- **Context-aware UI** - Different layouts for group vs. direct chats
- **Hover interactions** - Progress bar pausing, button feedback
- **Typography hierarchy** - Clear information organization and readability

### Technical Implementation
- **Tailwind CSS** - Utility-first styling with custom gradients
- **CSS animations** - Smooth transitions and progress indicators
- **JavaScript hooks** - Enhanced interactivity with LiveView integration
- **Mobile overlay** - Proper z-indexing and backdrop handling

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
│   ├── accounts/          # User management & presence
│   │   ├── user.ex        # User schema with status
│   │   └── accounts.ex    # User context & authentication
│   └── chat/              # Chat functionality
│       ├── room.ex        # Room schema
│       ├── message.ex     # Message schema (dual context)
│       ├── conversation.ex# Conversation schema
│       ├── room_membership.ex # Room membership
│       └── chat.ex        # Chat context & business logic
├── chatphoria_web/
│   ├── controllers/       # Authentication controllers
│   ├── live/              # LiveView components
│   │   └── chat_live.ex   # Main chat interface
│   └── components/        # UI components
│       └── core_components.ex # Enhanced flash messages
assets/
└── js/
    └── app.js             # LiveView hooks & JavaScript
priv/
└── repo/
    ├── migrations/        # Database schema evolution
    └── seeds.exs          # Sample data with conversations
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

## 🎯 What Makes Chatphoria Special

- **Dual Chat Modes** - Seamlessly switch between group discussions and private conversations
- **WhatsApp-like UX** - Familiar interface patterns that users already know and love  
- **Real-time Everything** - No page refreshes, just instant updates across all connected clients
- **Mobile-First Design** - Works beautifully on phones, tablets, and desktops
- **Smart Interactions** - Hover to pause timers, context-aware UI, intelligent notifications
- **Production Ready** - Comprehensive testing, proper error handling, and scalable architecture

## 🌟 Screenshots

### Group Chat Rooms
- Traditional chat interface with usernames and timestamps
- Room creation and management
- Real-time typing indicators

### Direct Messaging  
- WhatsApp-style message bubbles
- Your messages on the right (blue), theirs on the left (gray)
- Clean, distraction-free conversation view

### Mobile Experience
- Collapsible sidebar with hamburger menu
- Touch-optimized interface
- Responsive design that works on any screen size

---

**Chatphoria** - Where conversations come alive! 🎉
*The perfect blend of group collaboration and private messaging.*
