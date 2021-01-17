# require "spec_helper"
#
# describe ImageMasterFile do
#   describe "Page image relationships" do
#     it { respond_to :page_image_for }
#     it { respond_to :page_image_for= }
#
#     it "is manipulated as an array" do
#       begin
#         core_file = CoreFile.create(:did => "abcdefg", :depositor => "x")
#         imf = ImageMasterFile.create(:depositor => "x")
#         imf.page_image_for << core_file
#
#         expect(imf.page_image_for).to match_array [core_file]
#       ensure
#         core_file.delete if core_file.persisted?
#         imf.delete if imf.persisted?
#       end
#     end
#   end
#
#   it_behaves_like 'DownloadPath'
# end
