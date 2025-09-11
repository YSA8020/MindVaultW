# MindVault Website

A modern, responsive website for MindVault - Your Mental Health Companion.

## Features

- 🎨 **Modern Design**: Clean, professional interface with smooth animations
- 📱 **Responsive**: Works perfectly on desktop, tablet, and mobile
- ⚡ **Fast Performance**: Built with Next.js for optimal speed
- 🎯 **Interactive Demo**: Hands-on experience of MindVault features
- 📧 **Contact Form**: Easy way for users to get in touch
- 🔍 **SEO Optimized**: Proper meta tags and structured data

## Tech Stack

- **Framework**: Next.js 14 with TypeScript
- **Styling**: Tailwind CSS
- **Animations**: Framer Motion
- **Icons**: Lucide React
- **Deployment**: Vercel/Netlify ready

## Getting Started

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Run development server**:
   ```bash
   npm run dev
   ```

3. **Open your browser**:
   Navigate to [http://localhost:3000](http://localhost:3000)

## Project Structure

```
src/
├── pages/
│   ├── index.tsx          # Landing page
│   ├── demo.tsx           # Interactive demo
│   ├── _app.tsx           # App wrapper
│   └── _document.tsx     # Document wrapper
├── styles/
│   └── globals.css        # Global styles
└── components/            # Reusable components (future)
```

## Pages

### Landing Page (`/`)
- Hero section with compelling messaging
- Features showcase
- Statistics and social proof
- About section
- Contact form
- Footer with links

### Demo Page (`/demo`)
- Interactive step-by-step experience
- Mood selection
- Thought sharing
- AI response simulation
- Feature previews

## Customization

### Colors
The website uses a custom color palette defined in `tailwind.config.js`:
- Primary: Indigo shades
- Accent: Blue gradients
- Neutral: Gray scale

### Content
- Update text content in the respective page files
- Modify contact information in the contact section
- Add your own images and branding

### Styling
- Global styles in `src/styles/globals.css`
- Component-specific styles using Tailwind classes
- Custom animations and transitions

## Deployment

### Vercel (Recommended)
1. Push your code to GitHub
2. Connect your repository to Vercel
3. Deploy automatically

### Netlify
1. Build the project: `npm run build`
2. Upload the `out` folder to Netlify
3. Configure redirects for SPA routing

### Other Platforms
The website is static and can be deployed to any hosting service that supports HTML/CSS/JS.

## SEO Features

- Meta tags for social sharing
- Open Graph tags for Facebook/LinkedIn
- Twitter Card tags
- Structured data markup
- Semantic HTML structure
- Fast loading times

## Performance

- Optimized images and assets
- Minimal JavaScript bundle
- CSS purging with Tailwind
- Lazy loading for better UX
- Responsive images

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For questions or support, please contact us at hello@mindvault.app
