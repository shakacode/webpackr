require "pathname"
require "fileutils"
require "rake"
require "shakapacker/utils/misc"

GEM_ROOT = Pathname.new(File.expand_path("../../..", __FILE__))
SPEC_PATH = Pathname.new(File.expand_path("../", __FILE__))
BASE_RAILS_APP_PATH = SPEC_PATH.join("base-rails-app")
TEMP_RAILS_APP_PATH = SPEC_PATH.join("temp-rails-app")

describe "Generator" do
  before :all do
    FileUtils.rm_rf(TEMP_RAILS_APP_PATH)
    FileUtils.cp_r(BASE_RAILS_APP_PATH, TEMP_RAILS_APP_PATH)

    Bundler.with_unbundled_env do
      sh_in_dir(TEMP_RAILS_APP_PATH, [
        "bundle install",
        "FORCE=true rails shakapacker:install",
      ])
    end
  end

  after :all do
    Dir.chdir(SPEC_PATH)
    FileUtils.rm_rf(TEMP_RAILS_APP_PATH)
  end

  it "creates `config/shakapacker.yml`" do
    config_file_relative_path = "config/shakapacker.yml"
    actual_content, expected_content = fetch_content(config_file_relative_path)

    expect(actual_content).to eq expected_content
  end

  it "replaces package.json with template file" do
    actual_content = File.read(the_path("package.json"))

    expect(actual_content).to match /"name": "app",/
  end

  it "creates webpack config directory and its files" do
    expected_files = [
      "webpack.config.js"
    ]

    Dir.chdir(the_path("config/webpack")) do
      exisiting_files_in_config_webpack_dir = Dir.glob("*")
      expect(exisiting_files_in_config_webpack_dir).to eq expected_files
    end
  end

  it "adds binstubs" do
    expected_binstubs = []
    Dir.chdir(File.join(GEM_ROOT, "lib/install/bin")) do
      expected_binstubs = Dir.glob("bin/*")
    end

    Dir.chdir(File.join(TEMP_RAILS_APP_PATH, "bin")) do
      actual_binstubs = Dir.glob("*")
      expect(actual_binstubs).to include(*expected_binstubs)
    end
  end

  it "modifies .gitignore" do
    actual_content = File.read(the_path(".gitignore"))

    expect(actual_content).to match ".yarn-integrity"
  end

  it 'adds <%= javascript_pack_tag "application" %>' do
    actual_content = File.read(the_path("app/views/layouts/application.html.erb"))

    expect(actual_content).to match '<%= javascript_pack_tag "application" %>'
  end

  pending "updates `bin/setup"
  pending "updates CSP file. NOTICE: the very existance of this step is under question!"
  pending "installs relevant shakapacker version depending on webpacker version,"
  pending "installs peerdependencies"
  pending "it reports to the user if Webpacker installation failed"

  private
    def the_path(relative_path = nil)
      Pathname.new(File.join([TEMP_RAILS_APP_PATH, relative_path].compact))
    end

    def original_path(relative_path = nil)
      Pathname.new(File.join([GEM_ROOT, "lib/install" , relative_path].compact))
    end

    def fetch_content(the_file)
      file_path = the_path(the_file)
      original_file_path = original_path(the_file)
      actual_content = File.read(file_path)
      expected_content = File.read(original_file_path)

      [actual_content, expected_content]
    end

    def setup_project
      Dir.chdir(TEMP_RAILS_APP_PATH) do
        `bundle install`
        `bundle exec rails webpacker:install`
        $stdin = STDIN
      end
    end

    def sh_in_dir(dir, *shell_commands)
      Shakapacker::Utils::Misc.sh_in_dir(dir, shell_commands)
    end
end
