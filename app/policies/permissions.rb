# frozen_string_literal: true

# Single source of truth for the resource x action permission matrix.
# Each role's ability set is built by composing the tier below it
# (owner ⊇ admin ⊇ member), so a capability only needs to be listed once,
# at the tier where it's first granted.
module Permissions
  MEMBER_ABILITIES = %i[
    team_view
    project_view
    task_view
    task_manage
    membership_view
  ].freeze

  ADMIN_ABILITIES = (MEMBER_ABILITIES + %i[
    team_update
    project_manage
    membership_manage
    invitation_manage
    audit_log_view
  ]).freeze

  OWNER_ABILITIES = (ADMIN_ABILITIES + %i[
    team_destroy
  ]).freeze

  MATRIX = {
    member: MEMBER_ABILITIES.to_set,
    admin: ADMIN_ABILITIES.to_set,
    owner: OWNER_ABILITIES.to_set
  }.freeze

  def self.allowed?(role, ability)
    MATRIX.fetch(role&.to_sym, Set.new).include?(ability.to_sym)
  end
end
