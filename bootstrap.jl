(pwd() != @__DIR__) && cd(@__DIR__) # allow starting app from bin/ dir

using HelloOntarioWeatherApp
push!(Base.modules_warned_for, Base.PkgId(HelloOntarioWeatherApp))
HelloOntarioWeatherApp.main()
