export default {
  defaultBrowser: "Safari",
  handlers: [
    {
      match: /^https?:\/\/accounts\.google\.com\/o\/oauth2/,
      browser: "Safari",
    },
    {
      match: /^https?:\/\/meet\.google\.com\//,
      browser: (url) => ({
        name: "Google Chrome",
        profile: "Profile 2",
        args: [
          "--app-id=kjgfgldnnfoeklkmfkjfagphfepbbdan",
          `--app-launch-url-for-shortcuts-menu-item=${url.toString()}`,
        ],
      }),
    },
    {
      match: /^https?:\/\/(localhost|127\.0\.0\.1)([:/]|$)/,
      browser: "Google Chrome",
    },
    {
      match: /linear\.app/,
      browser: "Linear",
    },
    {
      match: /(^|\.)slack\.com/,
      browser: "Slack",
    },
    {
      match: /(^|\.)notion\.so/,
      browser: "Notion",
    },
  ],
};
