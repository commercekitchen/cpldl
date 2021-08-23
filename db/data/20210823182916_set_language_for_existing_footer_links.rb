class SetLanguageForExistingFooterLinks < ActiveRecord::Migration[5.2]
  def up
    FooterLink.update_all(language: Language.first)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
