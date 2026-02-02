class AddBackfillTrackingColumnsToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :attachments, :backfill_error, :text
    add_column :attachments, :backfill_failed_at, :datetime
  end
end
