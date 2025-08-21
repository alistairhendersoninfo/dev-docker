# Development Tools Reference

This document provides a comprehensive overview of all the development tools available in your Docker development environment.

## 🚀 Quick Start Commands

### Package Management

```bash
# Node.js
npm install package-name
yarn add package-name
pnpm add package-name

# Python
pip install package-name
poetry add package-name
pipenv install package-name
```

### Project Creation

```bash
# React
npx create-react-app my-app
# or
yarn create react-app my-app

# Next.js
npx create-next-app@latest my-app
# or
yarn create next-app my-app

# Vue
npm init vue@latest my-app

# Svelte
npm create svelte@latest my-app

# Astro
npm create astro@latest my-app
```

## 🛠️ Core Development Tools

### Version Control

- **Git**: Standard version control
- **GitHub CLI**: `gh` - GitHub operations from terminal
- **GitLab CLI**: `glab` - GitLab operations from terminal

### Text Editors & IDEs

- **Vim**: Terminal-based editor
- **Neovim**: Modern Vim fork
- **Cursor CLI**: Cursor editor command line tools

### Shell & Terminal

- **Zsh**: Advanced shell with plugins
- **Oh My Zsh**: Zsh configuration framework
- **tmux**: Terminal multiplexer
- **fzf**: Fuzzy finder for command line

## 🐍 Python Development

### Python Package Management

- **pip**: Standard Python package installer
- **Poetry**: Modern dependency management
- **Pipenv**: Virtual environment management

### Python Code Quality

- **Black**: Uncompromising code formatter
- **Flake8**: Style guide enforcement
- **MyPy**: Static type checking

### Testing

- **pytest**: Testing framework
- **pytest-cov**: Coverage reporting
- **pre-commit**: Git hooks for code quality

## 🟢 Node.js Development

### Node.js Package Managers

- **npm**: Node.js package manager
- **Yarn**: Fast, reliable package manager
- **pnpm**: Efficient package manager

### Build Tools

- **Vite**: Fast build tool
- **Webpack**: Module bundler
- **Gulp**: Task runner
- **Grunt**: Task runner

### Development Servers

- **live-server**: Live reload server
- **browser-sync**: Browser synchronization
- **http-server**: Simple HTTP server
- **serve**: Static file serving

### Framework CLIs

- **create-react-app**: React project setup
- **create-next-app**: Next.js project setup
- **create-vue-app**: Vue project setup
- **@angular/cli**: Angular CLI
- **@sveltejs/cli**: Svelte CLI
- **@astrojs/cli**: Astro CLI

## 🗄️ Database Tools

### ORMs & Query Builders

- **Prisma**: Database toolkit and ORM
- **TypeORM**: Object-relational mapping
- **Sequelize**: Promise-based ORM
- **Knex**: SQL query builder

### Database Clients

- **mongosh**: MongoDB shell
- **@databases/cli**: Database CLI tools

## 🧪 Testing & Quality

### JavaScript Testing

- **Jest**: Testing framework
- **Vitest**: Fast unit testing
- **Cypress**: E2E testing
- **Playwright**: Browser automation
- **@testing-library/cli**: Testing utilities

### Python Testing

- **pytest**: Testing framework
- **pytest-cov**: Coverage reporting

### Code Quality

- **ESLint**: JavaScript linting
- **Prettier**: Code formatting
- **Black**: Python formatting
- **Flake8**: Python linting

## 🚀 Deployment & DevOps

### Platform CLIs

- **@vercel/cli**: Vercel deployment
- **netlify-cli**: Netlify deployment
- **surge**: Static site deployment

### Container & Orchestration

- **docker-compose**: Container orchestration
- **kubectl**: Kubernetes CLI
- **helm**: Kubernetes package manager

### Infrastructure

- **terraform**: Infrastructure as code

## 🔍 Modern CLI Tools (Rust-based)

### File Operations

- **bat**: Better cat with syntax highlighting
- **exa**: Modern ls replacement
- **fd**: Fast file finder
- **du-dust**: Better du replacement

### Search & Processing

- **ripgrep**: Fast grep replacement
- **sd**: Intuitive find and replace
- **tokei**: Code metrics and statistics

### System Monitoring

- **bottom**: System monitor
- **procs**: Better ps replacement
- **htop**: Interactive process viewer

### Shell Enhancements

- **starship**: Cross-shell prompt
- **zoxide**: Smart cd replacement
- **tealdeer**: Fast tldr client

## 📚 Common Workflows

### New Web Project Setup

```bash
# 1. Create project
npx create-next-app@latest my-app --typescript --tailwind --eslint

# 2. Navigate to project
cd my-app

# 3. Start development server
npm run dev

# 4. Open in browser
# Navigate to http://localhost:3000
```

### Database Development

```bash
# 1. Initialize Prisma
npx prisma init

# 2. Create schema
npx prisma db push

# 3. Generate client
npx prisma generate

# 4. Open Prisma Studio
npx prisma studio
```

### Testing Workflow

```bash
# 1. Run tests
npm test

# 2. Run tests in watch mode
npm run test:watch

# 3. Run tests with coverage
npm run test:coverage

# 4. Run E2E tests
npx cypress open
```

### NPMCode Quality

```bash
# 1. Lint code
npm run lint

# 2. Format code
npm run format

# 3. Type check
npm run type-check

# 4. Pre-commit hooks
npx pre-commit run --all-files
```

## 🎯 AI-Assisted Development

### Cursor CLI

- AI-powered code completion
- Code generation and refactoring
- Natural language to code conversion

### OpenCode CLI

- AI code analysis
- Automated code reviews
- Intelligent refactoring suggestions

### Claude CLI

- AI coding assistant
- Code explanation and documentation
- Bug finding and fixing suggestions

## 🔧 Customization

### Zsh Configuration

```bash
# Edit zsh configuration
nano ~/.zshrc

# Popular themes
# robbyrussell, agnoster, powerlevel10k

# Useful plugins
# git, docker, npm, python, zsh-autosuggestions
```

### tmux Configuration

```bash
# Edit tmux configuration
nano ~/.config/tmux/tmux.conf

# Start new session
tmux new-session -s dev

# Attach to session
tmux attach-session -t dev
```

### Starship Prompt

```bash
# Edit starship configuration
nano ~/.config/starship.toml

# Customize prompt appearance
# Show git status, Python version, Node version, etc.
```

## 📖 Learning Resources

### Official Documentation

- [Next.js Docs](https://nextjs.org/docs)
- [React Docs](https://react.dev)
- [Vue Docs](https://vuejs.org/guide)
- [Prisma Docs](https://www.prisma.io/docs)
- [Playwright Docs](https://playwright.dev)

### CLI Tool Documentation

- [Starship](https://starship.rs)
- [Rust Tools](https://rust-lang.github.io/rustup)
- [Oh My Zsh](https://ohmyz.sh)

### Best Practices

- Use TypeScript for type safety
- Implement proper testing strategies
- Follow code formatting standards
- Use pre-commit hooks for quality
- Leverage AI tools for productivity

---

**Note**: This environment is designed for modern web development workflows. All tools are pre-installed and ready to use immediately after SSH'ing into any container.
