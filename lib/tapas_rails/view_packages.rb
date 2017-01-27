module TapasRails
  module ViewPackages
    def available_view_packages
      Rails.cache.fetch("view_packages", expires_in: 48.hours) do
        ViewPackage.where("").pluck(:machine_name).to_a
      end
    end
  end
end
