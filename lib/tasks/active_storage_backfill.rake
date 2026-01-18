namespace :active_storage do
  desc "Backfill CKEditor assets into ActiveStorage. Usage: rake active_storage:backfill_ckeditor[start_id,batch_size]"
  task :backfill_ckeditor, [:start_id, :batch_size] => :environment do |_, args|
    start_id = args[:start_id].presence&.to_i
    batch_size = (args[:batch_size].presence || 200).to_i

    BackfillCkeditorAssetsJob.perform_later(start_id: start_id, batch_size: batch_size)

    puts "Enqueued BackfillCkeditorAssetsJob (start_id=#{start_id || 'nil'}, batch_size=#{batch_size})"
  end

  desc "Backfill course attachments into ActiveStorage. Usage: rake active_storage:backfill_attachments[start_id,batch_size]"
  task :backfill_attachments, [:start_id, :batch_size] => :environment do |_, args|
    start_id = args[:start_id].presence&.to_i
    batch_size = (args[:batch_size].presence || 200).to_i

    BackfillAttachmentsJob.perform_later(start_id: start_id, batch_size: batch_size)

    puts "Enqueued BackfillAttachmentsJob (start_id=#{start_id || 'nil'}, batch_size=#{batch_size})"
  end

  desc "Show backfill status counts"
  task :status => :environment do
    puts "Attachments remaining: #{Attachment.where(migrated_to_active_storage_at: nil).count}"
    puts "CKEditor remaining:   #{Ckeditor::Asset.where(migrated_to_active_storage_at: nil).count}"
  end
end
