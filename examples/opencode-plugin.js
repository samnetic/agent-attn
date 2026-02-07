export const AgentAttentionPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "permission.asked") {
        await $`bash -lc '~/.local/bin/agent-attn --app "OpenCode" --event "permission.asked" --message "Approval required"'`
      }

      if (event.type === "session.idle") {
        await $`bash -lc '~/.local/bin/agent-attn --app "OpenCode" --event "session.idle" --message "Response ready"'`
      }
    },
  }
}
