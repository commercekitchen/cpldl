class AddLanguageToFooterLinks < ActiveRecord::Migration[5.2]
  def change
    add_reference :footer_links, :language, index: true
    add_foreign_key :footer_links, :languages
  end
end
