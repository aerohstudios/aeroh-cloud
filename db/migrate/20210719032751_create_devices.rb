class CreateDevices < ActiveRecord::Migration[6.1]
  def change
    create_table :devices do |t|
      t.string  :name
      t.string  :mac_addr

      t.boolean :provisioned, default: false
      t.string  :thing_arn

      t.boolean :cert_active, default: false
      t.string  :certificate_arn
      t.text    :certificate_pem
      t.text    :certificate_public_key
      t.text    :certificate_private_key

      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
