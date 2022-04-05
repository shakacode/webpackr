require "test_helper"

class CompilerTest < Minitest::Test
  def remove_compilation_timestamp_path
    Webpacker.compiler.send(:compilation_timestamp_path).tap do |path|
      path.delete if path.exist?
    end
  end

  def setup
    remove_compilation_timestamp_path
  end

  def teardown
    remove_compilation_timestamp_path
  end

  def test_custom_environment_variables
    assert_nil Webpacker.compiler.send(:webpack_env)["FOO"]
    Webpacker.compiler.env["FOO"] = "BAR"
    assert Webpacker.compiler.send(:webpack_env)["FOO"] == "BAR"
  ensure
    Webpacker.compiler.env = {}
  end

  def test_freshness
    assert Webpacker.compiler.stale?
    assert !Webpacker.compiler.fresh?
  end

  def test_compile
    assert !Webpacker.compiler.compile
  end

  def test_freshness_on_compile_success
    status = OpenStruct.new(success?: true)

    assert Webpacker.compiler.stale?
    Open3.stub :capture3, [:sterr, :stdout, status] do
      Webpacker.compiler.compile
      assert Webpacker.compiler.fresh?
    end
  end

  def test_freshness_on_compile_fail
    status = OpenStruct.new(success?: false)

    assert Webpacker.compiler.stale?
    Open3.stub :capture3, [:sterr, :stdout, status] do
      Webpacker.compiler.compile
      assert Webpacker.compiler.fresh?
    end
  end

  def test_compilation_timestamp_path
    assert_equal Webpacker.compiler.send(:compilation_timestamp_path).basename.to_s, "last-compilation-timestamp-#{Webpacker.env}"
  end

  def test_external_env_variables
    assert_nil Webpacker.compiler.send(:webpack_env)["WEBPACKER_ASSET_HOST"]
    assert_nil Webpacker.compiler.send(:webpack_env)["WEBPACKER_RELATIVE_URL_ROOT"]

    ENV["WEBPACKER_ASSET_HOST"] = "foo.bar"
    ENV["WEBPACKER_RELATIVE_URL_ROOT"] = "/baz"
    assert_equal Webpacker.compiler.send(:webpack_env)["WEBPACKER_ASSET_HOST"], "foo.bar"
    assert_equal Webpacker.compiler.send(:webpack_env)["WEBPACKER_RELATIVE_URL_ROOT"], "/baz"
  end
end
