import { defineConfig } from 'vitepress'

// GitHub Pages serves a project site under /<repository>/; the deploy workflow
// sets DOCS_BASE from the repository name. Locally the site lives at /.
const base = process.env.DOCS_BASE || '/'

export default defineConfig({
  base,
  title: 'Kismet for OpenWrt',
  description:
    'Kismet wireless sniffer, web UI and RTL-SDR tools packaged for OpenWrt 25.12 routers (apk, aarch64_cortex-a53).',
  lang: 'en',
  cleanUrls: true,
  lastUpdated: false,
  srcExclude: ['**/node_modules/**'],
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: `${base}logo.svg` }],
    ['meta', { name: 'theme-color', content: '#2f9e6e' }],
  ],
  themeConfig: {
    logo: '/logo.svg',
    nav: [
      { text: 'Guide', link: '/guide/getting-started', activeMatch: '/guide/' },
      { text: 'Features', link: '/features/server', activeMatch: '/features/' },
      { text: 'Reference', link: '/reference/configuration', activeMatch: '/reference/' },
      { text: 'Hardware', link: '/hardware/gl-axt1800', activeMatch: '/hardware/' },
    ],
    sidebar: [
      {
        text: 'Guide',
        items: [
          { text: 'Getting started', link: '/guide/getting-started' },
          { text: 'Installation', link: '/guide/installation' },
          { text: 'Troubleshooting', link: '/guide/troubleshooting' },
        ],
      },
      {
        text: 'Features',
        items: [
          { text: 'Kismet on the router', link: '/features/server' },
          { text: 'Wi-Fi capture', link: '/features/wifi-capture' },
          { text: 'Remote capture to a PC', link: '/features/remote-capture' },
          { text: 'SDR: aircraft, sensors, ships', link: '/features/sdr' },
          { text: 'Logging and pcap export', link: '/features/logging' },
        ],
      },
      {
        text: 'Reference',
        items: [
          { text: 'Configuration', link: '/reference/configuration' },
          { text: 'Commands', link: '/reference/commands' },
          { text: 'Packages', link: '/reference/packages' },
          { text: 'Security', link: '/reference/security' },
          { text: 'Building', link: '/reference/building' },
        ],
      },
      {
        text: 'Hardware',
        items: [
          { text: 'GL.iNet GL-AXT1800', link: '/hardware/gl-axt1800' },
          { text: 'Other routers', link: '/hardware/other-routers' },
        ],
      },
    ],
    socialLinks: [{ icon: 'github', link: 'https://github.com/miercolesv/kismet-capture-openwrt' }],
    editLink: {
      pattern: 'https://github.com/miercolesv/kismet-capture-openwrt/edit/main/docs/:path',
      text: 'Edit this page on GitHub',
    },
    search: { provider: 'local' },
    outline: { level: [2, 3], label: 'On this page' },
    footer: {
      message:
        'Kismet is GPL-2.0. Not affiliated with Kismet, OpenWrt or any router manufacturer.',
    },
  },
})
