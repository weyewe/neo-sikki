# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20130902023420) do

  create_table "deceased_principal_receivables", force: true do |t|
    t.integer  "member_id"
    t.decimal  "amount_receivable", precision: 12, scale: 2, default: 0.0
    t.decimal  "amount_received",   precision: 12, scale: 2, default: 0.0
    t.boolean  "is_closed",                                  default: false
    t.string   "payment_document"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_default_payments", force: true do |t|
    t.integer  "group_loan_membership_id"
    t.integer  "group_loan_id"
    t.decimal  "amount_receivable",            precision: 12, scale: 2, default: 0.0
    t.decimal  "compulsory_savings_deduction", precision: 12, scale: 2, default: 0.0
    t.decimal  "remaining_amount_receivable",  precision: 12, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_disbursements", force: true do |t|
    t.integer  "group_loan_membership_id"
    t.integer  "group_loan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_memberships", force: true do |t|
    t.integer  "group_loan_id"
    t.integer  "group_loan_product_id"
    t.integer  "member_id"
    t.boolean  "is_active",                                        default: true
    t.integer  "deactivation_case"
    t.integer  "deactivation_week_number"
    t.decimal  "total_compulsory_savings", precision: 9, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_port_compulsory_savings", force: true do |t|
    t.integer  "group_loan_id"
    t.integer  "group_loan_membership_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_products", force: true do |t|
    t.string   "name"
    t.decimal  "principal",          precision: 9, scale: 2, default: 0.0
    t.decimal  "interest",           precision: 9, scale: 2, default: 0.0
    t.decimal  "compulsory_savings", precision: 9, scale: 2, default: 0.0
    t.decimal  "admin_fee",          precision: 9, scale: 2, default: 0.0
    t.decimal  "initial_savings",    precision: 9, scale: 2, default: 0.0
    t.integer  "total_weeks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_run_away_receivable_payments", force: true do |t|
    t.integer  "group_loan_run_away_receivable_id"
    t.integer  "group_loan_weekly_collection_id"
    t.integer  "group_loan_membership_id"
    t.integer  "group_loan_id"
    t.decimal  "amount",                            precision: 12, scale: 2, default: 0.0
    t.integer  "payment_case"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_run_away_receivables", force: true do |t|
    t.integer  "member_id"
    t.integer  "group_loan_membership_id"
    t.integer  "group_loan_id"
    t.integer  "group_loan_weekly_collection_id"
    t.decimal  "amount_receivable",               precision: 12, scale: 2, default: 0.0
    t.boolean  "is_closed",                                                default: false
    t.integer  "payment_case"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_weekly_collections", force: true do |t|
    t.integer  "group_loan_id"
    t.integer  "week_number"
    t.boolean  "is_collected",          default: false
    t.boolean  "is_confirmed",          default: false
    t.datetime "collection_datetime"
    t.datetime "confirmation_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_weekly_payments", force: true do |t|
    t.integer  "group_loan_membership_id"
    t.integer  "group_loan_id"
    t.integer  "group_loan_weekly_collection_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_weekly_uncollectibles", force: true do |t|
    t.integer  "group_loan_weekly_collection_id"
    t.integer  "group_loan_membership_id"
    t.integer  "group_loan_id"
    t.decimal  "amount",                          precision: 12, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loans", force: true do |t|
    t.string   "name"
    t.integer  "number_of_meetings"
    t.integer  "number_of_collections"
    t.boolean  "is_started",                                            default: false
    t.boolean  "is_loan_disbursement_prepared",                         default: false
    t.boolean  "is_loan_disbursed",                                     default: false
    t.boolean  "is_closed",                                             default: false
    t.integer  "group_leader_id"
    t.decimal  "run_away_amount_receivable",    precision: 9, scale: 2, default: 0.0
    t.decimal  "run_away_amount_received",      precision: 9, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", force: true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "id_number"
    t.decimal  "total_savings_account", precision: 12, scale: 2, default: 0.0
    t.boolean  "is_deceased",                                    default: false
    t.datetime "death_datetime"
    t.boolean  "is_run_away",                                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name",        null: false
    t.string   "title",       null: false
    t.text     "description", null: false
    t.text     "the_role",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "savings_entries", force: true do |t|
    t.integer  "savings_source_id"
    t.string   "savings_source_type"
    t.decimal  "amount",                 precision: 9, scale: 2, default: 0.0
    t.integer  "savings_status"
    t.integer  "direction"
    t.integer  "financial_product_id"
    t.string   "financial_product_type"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_activities", force: true do |t|
    t.integer  "transaction_source_id"
    t.string   "transaction_source_type"
    t.integer  "fund_case"
    t.decimal  "amount",                  precision: 9, scale: 2, default: 0.0
    t.integer  "direction"
    t.decimal  "savings",                 precision: 9, scale: 2, default: 0.0
    t.integer  "savings_direction"
    t.integer  "office_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "role_id"
    t.string   "name"
    t.string   "username"
    t.string   "login"
    t.boolean  "is_deleted",             default: false
    t.boolean  "is_main_user",           default: false
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
