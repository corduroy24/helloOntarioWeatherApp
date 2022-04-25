module HelloOntarioWeatherApp

using Genie, Logging, LoggingExtras

function main()
  Core.eval(Main, :(const UserApp = $(@__MODULE__)))

  Genie.genie(; context = @__MODULE__)

  Core.eval(Main, :(const Genie = UserApp.Genie))
  Core.eval(Main, :(using Genie))
end

end


function launchServer(port)

  Genie.config.run_as_server = true
  Genie.config.server_host = "0.0.0.0"
  Genie.config.server_port = port

  println("port set to $(port)")

  route("/") do
      "Hi there!"
  end

  Genie.AppServer.startup()
end

launchServer(parse(Int, ARGS[1]))
