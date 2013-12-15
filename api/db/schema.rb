# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2) do

  create_table "subdomains", force: true do |t|
    t.string   "endpoint"
    t.string   "name"
    t.string   "scheme",              default: "http"
    t.integer  "port"
    t.text     "ssh_public_key"
    t.text     "ssh_private_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "openssl_certificate"
  end

  add_index "subdomains", ["port"], name: "index_subdomains_on_port"

end
