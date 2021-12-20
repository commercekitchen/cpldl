require 's3_uploader'

namespace :s3_migration do
  desc "Copy all attachments to S3"
  task upload_attachments: :environment do
    uploader = S3Uploader.new

    begin
      [
        { model: Attachment, attachment_name: "document" },
        { model: Organization, attachment_name: "footer_logo" },
        { model: Ckeditor::AttachmentFile, attachment_name: "data" },
        { model: Ckeditor::Picture, attachment_name: "data", styles: true }
      ].each do |upload_options|
        model = upload_options[:model]
        attachment_name = upload_options[:attachment_name]
        styles = upload_options[:styles]

        puts "Migrating #{model.count} #{model.name.pluralize}"
        model.find_each do |record|
          if styles
            record.send(attachment_name).styles.each do |style|
              uploader.copy_to_s3!(record, attachment_name: attachment_name, style: style[0])
            end
          else
            uploader.copy_to_s3!(record, attachment_name: attachment_name)
          end
        end
      end
    rescue Exception => e
      puts "Could not process materials: #{e}"
    end
  end
end
