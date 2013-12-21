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

ActiveRecord::Schema.define(version: 1) do

  create_table "subdomain_ports", force: true do |t|
    t.integer  "port"
    t.integer  "subdomain_id"
    t.string   "protocol",     default: "tcp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subdomain_ports", ["port"], name: "index_subdomain_ports_on_port", unique: true
  add_index "subdomain_ports", ["subdomain_id"], name: "index_subdomain_ports_on_subdomain_id"

  create_table "subdomains", force: true do |t|
    t.string   "token"
    t.string   "endpoint"
    t.string   "fqdn"
    t.text     "ssh_public_key"
    t.text     "ssh_private_key"
    t.text     "openssl_certificate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subdomains", ["fqdn"], name: "index_subdomains_on_fqdn", unique: true

end
