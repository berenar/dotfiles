import type { Plugin } from "@opencode-ai/plugin";

export const EnvProtection: Plugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (
        input.tool !== "edit" &&
        input.tool !== "shell" &&
        input.tool !== "bash"
      ) {
        return;
      }

      const filePath = output.args.filePath;
      if (filePath?.includes(".env")) {
        throw new Error(
          `🚫 I'm not allowed to write .env files like this one \n ${filePath}`,
        );
      }

      const command = output.args.command;
      if (command?.includes(".env")) {
        throw new Error(
          `🚫 I'm not allowed to execute commands that interact with .env files`,
        );
      }
    },
  };
};
