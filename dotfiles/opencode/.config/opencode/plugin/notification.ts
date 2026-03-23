import type { Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  type PermissionAskedEvent = {
    type: "permission.asked";
    properties: {
      permission: string;
      patterns: string[];
    };
  };

  type AssistantMessageUpdatedEvent = {
    type: "message.updated";
    properties: {
      info: {
        id: string;
        sessionID: string;
        role: "assistant" | "user";
      };
    };
  };

  type MessagePartUpdatedEvent = {
    type: "message.part.updated";
    properties: {
      part: {
        sessionID: string;
        messageID: string;
        type: string;
        text?: string;
      };
      delta?: string;
    };
  };

  type SessionIdleEvent = {
    type: "session.idle";
    properties: {
      sessionID: string;
    };
  };

  const ntfyTopic = "opencode-berenar-a8f3k2x9q1";
  const ntfyBaseUrl = "https://ntfy.sh";
  const maxPhoneMessageLength = 500;
  const lastAssistantBySession = new Map<
    string,
    {
      messageID: string;
      text: string;
    }
  >();

  const isKittyFocused = async (): Promise<boolean> => {
    const result =
      await $`osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`.text();
    return result.trim() === "kitty";
  };

  const sendDesktopNotification = async (message: string) => {
    const script = `display notification ${JSON.stringify(message)} with title "opencode" sound name "Pop"`;
    await $`osascript -e ${script}`;
  };

  const sendPhoneNotification = async (message: string) => {
    if (!ntfyTopic) {
      return;
    }

    await fetch(`${ntfyBaseUrl}/${ntfyTopic}`, {
      method: "POST",
      headers: {
        Title: "opencode",
        Priority: "default",
      },
      body: message,
    });
  };

  const sendNotification = async (message: string) => {
    await Promise.allSettled([
      sendDesktopNotification(message),
      sendPhoneNotification(message),
    ]);
  };

  const formatPhoneMessage = (message: string) => {
    const trimmedMessage = message.trim();
    if (trimmedMessage.length <= maxPhoneMessageLength) {
      return trimmedMessage;
    }

    return `${trimmedMessage.slice(0, maxPhoneMessageLength - 1).trimEnd()}...`;
  };

  const getLastAssistantText = async (sessionID: string) => {
    const cachedMessage = lastAssistantBySession.get(sessionID);
    if (cachedMessage?.text.trim()) {
      return cachedMessage.text;
    }

    const response = await client.session.messages({
      path: { id: sessionID },
      query: { directory, limit: 20 },
    });

    if (response.error || !response.data) {
      return "";
    }

    const latestAssistantMessage = [...response.data]
      .reverse()
      .find((message) => message.info.role === "assistant");

    if (!latestAssistantMessage) {
      return "";
    }

    const assistantText = latestAssistantMessage.parts
      .filter((part) => part.type === "text")
      .map((part) => part.text)
      .join("")
      .trim();

    if (!assistantText) {
      return "";
    }

    lastAssistantBySession.set(sessionID, {
      messageID: latestAssistantMessage.info.id,
      text: assistantText,
    });

    return assistantText;
  };

  return {
    event: async ({ event }) => {
      const permissionEvent = event as unknown as PermissionAskedEvent;
      const assistantMessageUpdatedEvent =
        event as unknown as AssistantMessageUpdatedEvent;
      const messagePartUpdatedEvent = event as unknown as MessagePartUpdatedEvent;
      const sessionIdleEvent = event as unknown as SessionIdleEvent;

      if (permissionEvent.type === "permission.asked") {
        const kittyFocused = await isKittyFocused();
        if (!kittyFocused) {
          const permission = permissionEvent.properties.permission;
          const patterns = permissionEvent.properties.patterns.join(", ");
          await sendNotification(
            `Permission required: ${permission} (${patterns})`,
          );
        }
      }

      if (assistantMessageUpdatedEvent.type === "message.updated") {
        const message = assistantMessageUpdatedEvent.properties.info;
        if (message.role === "assistant") {
          const currentMessage = lastAssistantBySession.get(message.sessionID);
          if (!currentMessage || currentMessage.messageID !== message.id) {
            lastAssistantBySession.set(message.sessionID, {
              messageID: message.id,
              text: "",
            });
          }
        }
      }

      if (messagePartUpdatedEvent.type === "message.part.updated") {
        const { part, delta } = messagePartUpdatedEvent.properties;
        if (part.type !== "text") {
          return;
        }

        const currentMessage = lastAssistantBySession.get(part.sessionID);
        if (!currentMessage || currentMessage.messageID !== part.messageID) {
          return;
        }

        const nextText = delta ?? part.text ?? "";
        if (!nextText) {
          return;
        }

        lastAssistantBySession.set(part.sessionID, {
          ...currentMessage,
          text: `${currentMessage.text}${nextText}`,
        });
      }

      if (sessionIdleEvent.type === "session.idle") {
        const kittyFocused = await isKittyFocused();
        if (!kittyFocused) {
          const assistantText = await getLastAssistantText(
            sessionIdleEvent.properties.sessionID,
          );
          const message = assistantText
            ? `OpenCode reply\n\n${formatPhoneMessage(assistantText)}`
            : "Hey! Waiting for you...";

          await sendNotification(message);
        }
      }
    },
  };
};
