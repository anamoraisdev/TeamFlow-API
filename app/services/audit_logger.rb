# frozen_string_literal: true

# Explicit call sites (no callback magic) so it's obvious from reading a
# controller action exactly what gets audited and with what metadata.
class AuditLogger
  def self.record(team:, user:, action:, auditable: nil, metadata: {})
    AuditLog.create!(
      team: team,
      user: user,
      action: action,
      auditable: auditable,
      metadata: metadata
    )
  end
end
