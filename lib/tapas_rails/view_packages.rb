module TapasRails
  module ViewPackages
    def available_view_packages_machine
      Rails.cache.fetch("view_packages_machine", expires_in: 48.hours) do
        ViewPackage.where("").pluck(:machine_name).to_a
      end
    end

    def available_view_packages_dir
      Rails.cache.fetch("view_packages_dir", expires_in: 48.hours) do
        ViewPackage.where("").pluck(:dir_name).to_a
      end
    end
  end
end
