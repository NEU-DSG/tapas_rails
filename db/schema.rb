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

ActiveRecord::Schema.define(version: 2020_07_27_210248) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "bookmarks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_type"
    t.string "document_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_type"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "captions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "active_storage_attachment_id"
    t.index ["active_storage_attachment_id"], name: "index_captions_on_active_storage_attachment_id"
  end

  create_table "collection_collections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "collection_id"
    t.integer "parent_collection_id", null: false
    t.index ["collection_id", "parent_collection_id"], name: "index_collections_parent", unique: true
    t.index ["collection_id"], name: "index_collection_collections_on_collection_id"
  end

  create_table "collections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "community_id", null: false
    t.boolean "is_public"
    t.integer "depositor_id", null: false
    t.datetime "discarded_at"
    t.index ["depositor_id"], name: "index_collections_on_depositor_id"
    t.index ["discarded_at"], name: "index_collections_on_discarded_at"
  end

  create_table "collections_core_files", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "core_file_id"
    t.bigint "collection_id"
    t.index ["collection_id", "core_file_id"], name: "index_collections_core_files_on_collection_id_and_core_file_id", unique: true
    t.index ["collection_id"], name: "index_collections_core_files_on_collection_id"
    t.index ["core_file_id"], name: "index_collections_core_files_on_core_file_id"
  end

  create_table "communities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_public", default: true
    t.integer "depositor_id", null: false
    t.datetime "discarded_at"
    t.index ["depositor_id"], name: "index_communities_on_depositor_id"
    t.index ["discarded_at"], name: "index_communities_on_discarded_at"
  end

  create_table "communities_institutions", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "community_id", null: false
    t.bigint "institution_id", null: false
    t.index ["community_id", "institution_id"], name: "index_communities_instutitions", unique: true
    t.index ["institution_id", "community_id"], name: "index_institutions_communities", unique: true
  end

  create_table "community_collections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "collection_id"
    t.bigint "community_id"
    t.index ["collection_id", "community_id"], name: "index_community_collections_on_collection_id_and_community_id", unique: true
    t.index ["collection_id"], name: "index_community_collections_on_collection_id"
    t.index ["community_id"], name: "index_community_collections_on_community_id"
  end

  create_table "community_communities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "community_id"
    t.integer "parent_community_id", null: false
    t.index ["community_id", "parent_community_id"], name: "index_community_parent", unique: true
    t.index ["community_id"], name: "index_community_communities_on_community_id"
  end

  create_table "community_members", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "community_id"
    t.bigint "user_id"
    t.string "member_type", limit: 6, default: "member"
    t.index ["community_id", "user_id"], name: "index_community_members_on_community_id_and_user_id", unique: true
    t.index ["community_id"], name: "index_community_members_on_community_id"
    t.index ["user_id"], name: "index_community_members_on_user_id"
  end

  create_table "core_files", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_public", default: true
    t.integer "depositor_id", null: false
    t.boolean "featured"
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_core_files_on_discarded_at"
  end

  create_table "core_files_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "core_file_id", null: false
    t.string "user_type", limit: 11, default: "contributor", null: false
    t.index ["core_file_id", "user_id"], name: "index_core_files_users_on_core_file_id_and_user_id", unique: true
    t.index ["user_id", "core_file_id"], name: "index_core_files_users_on_user_id_and_core_file_id", unique: true
  end

  create_table "friendly_id_slugs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "institutions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "image"
    t.string "address"
    t.string "latitude"
    t.string "longitude"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "menu_links", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "link_text", null: false
    t.string "link_href", null: false
    t.string "classes"
    t.integer "link_order"
    t.integer "parent_link_id"
    t.string "menu_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "news_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "author"
    t.string "publish"
    t.string "title", null: false
    t.string "slug", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tags"
  end

  create_table "pages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.text "content"
    t.string "publish"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "submenu"
  end

  create_table "searches", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "query_params"
    t.integer "user_id"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "guest", default: false
    t.string "encrypted_api_key"
    t.string "name"
    t.bigint "institution_id"
    t.string "avatar"
    t.text "bio"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.text "account_type"
    t.datetime "admin_at"
    t.datetime "paid_at"
    t.datetime "discarded_at"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["institution_id"], name: "index_users_on_institution_id"
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "view_packages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "human_name"
    t.string "machine_name"
    t.text "description"
    t.text "file_type"
    t.text "css_files"
    t.text "js_files"
    t.text "parameters"
    t.text "run_process"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dir_name"
    t.datetime "git_timestamp"
    t.string "git_branch"
  end

  add_foreign_key "captions", "active_storage_attachments"
end
