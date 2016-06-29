ESpec.configure fn(config) ->
  config.before fn ->
    ExVCR.Config.cassette_library_dir("spec/fixtures/vcr_cassettes")
    :ok
  end

  config.finally fn(_shared) ->
    :ok
  end
end
