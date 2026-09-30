class Notification < ApplicationRecord
  belongs_to :user

  validates :category, presence: true
  validates :title, presence: true

  scope :unread, -> { where(read_at: nil) }

  def mark_read!
    update!(read_at: Time.current) if read_at.nil?
  end
end
