module FileHelpers
  def fixture_file(fname)
    return Rails.root.join("spec/fixtures/files", fname).to_s
  end

  def tmp_fixture_file(fname)
    return Rails.root.join("tmp", fname).to_s
  end

  def copy_fixture(src_file, dest_file)
    src = Rails.root.join("spec/fixtures/files", src_file)
    dest = Rails.root.join("tmp/", dest_file)

    FileUtils.cp(src.to_s, dest.to_s)
    return dest.to_s
  end
end
