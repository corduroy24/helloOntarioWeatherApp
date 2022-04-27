using Stipple
using StippleUI
using StipplePlotly
# using PlotlyBase
using Genie.Renderer.Html 
using Genie

using CSV
using DataFrames
# import RDatasets: dataset
# import DataFrames
using Query
# using Plots
# using StatsPlots
using Statistics
using Dates
using StatsBase
using SeasonalTrendLoess
using TimeSeries


data = CSV.read("toronto-city-centre-combined-daily-climate.csv", DataFrame)
# data.LOCAL_DATE = Date.(data.LOCAL_DATE, DateFormat("yyyy-mm-dd H:M:S"))
# DataFrames.select(data, :LOCAL_DATE, :MEAN_TEMPERATURE)
station = data |> @filter(_.STATION_NAME == "TORONTO CITY CENTRE") |> DataFrame
sort!(station, :LOCAL_DATE)
ta = TimeArray(station.LOCAL_DATE, station.MEAN_TEMPERATURE)
TimeSeries.rename!(ta, :MEAN_TEMPERATURE)

# # check for stationarity - because of the assumption
temp = DataFrames.select(station, :LOCAL_DATE, :MEAN_TEMPERATURE)
temp_arr = Core.Array(temp[:, 2])

function ffill(v)
  v[accumulate(max, [i*!ismissing(v[i]) for i in 1:length(v)], init=1)]
end

check = ffill(temp_arr)
# sum(ismissing.(check))
check = Core.Array{Float64}(check)

stl_meanTemp = SeasonalTrendLoess.stl(check, 365)
# dispplay in panel, 4 rows
# p1 = Plots.Plot(ta[:MEAN_TEMPERATURE], label = "", ylabel = "Observed")
# p2 = Plots.plot(stl_meanTemp.trend, label = "", ylabel = "Trend")
# p3 = Plots.plot(stl_meanTemp.seasonal, label = "", ylabel = "Season")
# p4 = Plots.plot(stl_meanTemp.remainder, label = "", ylabel = "Remainder")



xx = -π:(2π/250):π

xxs = -3.0:0.2:3.0

# Plots.plot(PlotData(
#   x = station.LOCAL_DATE,
#   y = check,
#   name = "hello",
#   plot = StipplePlotly.Charts.PLOT_TYPE_LINE
# ))
ps1 = PlotData(
    x = xxs, y = sin.(xxs) .+ rand(Float64, size(xxs)) .- 0.5, plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
    name = "sine", mode = "markers", xaxis = "x", yaxis = "y", marker = PlotDataMarker(color="rgb(0,0,192)", symbol="circle", size=10, opacity=0.5)
)

ps2 = PlotData(
    x = xxs, y = sinh.(xxs) .+ 3.0 .* rand(Float64, size(xxs)) .- 1.5, plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
    name = "sinh", mode = "markers", xaxis = "x2", yaxis = "y2", marker = PlotDataMarker(color = "rgb(0,192,0)", symbol="circle-open", size=14)
)

ps3 = PlotData(
    x = xxs, y = cos.(xxs) .+ rand(Float64, size(xxs)) .- 0.5, plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
    name = "cosine", mode = "markers", xaxis = "x3", yaxis = "y3", marker = PlotDataMarker(color = "rgb(192,0,0)", symbol="diamond", size=10, opacity=0.5)
)

ps4 = PlotData(
    x = xxs, y = cosh.(xxs) .+ 3.0 .* rand(Float64, size(xxs)) .- 1.5, plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
    name = "cosh", mode = "markers", xaxis = "x4", yaxis = "y4", marker = PlotDataMarker(color = "rgb(192,0,192)", symbol="diamond-open", size=3)
)

layoutTest = PlotLayout(
    width = 4,
    height = 2
)

const ALL_REGIONS = "all"
const REGIONS = String[ALL_REGIONS, "au", "cn-east", "cn-northeast", "cn-southeast", "eu-central", "in", "kr", "sa", "sg", "us-east", "us-west"]

const DAY = "day"
const MONTH = "month"
const YEAR = "year"

p1 = PlotData(
    x = last(temp.LOCAL_DATE, 30),
    y = last(check, 30),
    plot = StipplePlotly.Charts.PLOT_TYPE_LINE,
    name = "Observed",
)

p2 = PlotData(
    x = last(temp.LOCAL_DATE, 30),
    y = last(stl_meanTemp.trend, 30),
    plot = StipplePlotly.Charts.PLOT_TYPE_LINE,
    name = "Trend",
)

p3= PlotData(
    x = last(temp.LOCAL_DATE, 30),
    y = last(stl_meanTemp.seasonal, 30),
    plot = StipplePlotly.Charts.PLOT_TYPE_LINE,
    name = "Season",
)

p4 = PlotData(
    x = last(temp.LOCAL_DATE, 30),
    y = last(stl_meanTemp.remainder, 30),
    plot = StipplePlotly.Charts.PLOT_TYPE_LINE,
    name = "Remainder",
)

plotdata = [p1,  p2,  p3,  p4]


@reactive mutable struct seriesModel  <: ReactiveModel
  # filter UI
  # plot::R{Plot} = Plot()
  searchterms::R{Vector{String}} = String[]
  packages::Vector{String} = []
  filter_startdate::R{Date} = Dates.today() - Dates.Month(3)
  filter_enddate::R{Date} = Dates.today() - Dates.Day(1)

  regions::Vector{String} = REGIONS
  filter_regions::R{Vector{String}} = String[ALL_REGIONS]

  interval::R{String} = DAY
  plot_1::R{PlotData} = plotdata[1]
  plot_2::R{PlotData} = plotdata[2]
  plot_3::R{PlotData} = plotdata[3]
  plot_4::R{PlotData} = plotdata[4]

  # layout::R(PlotLayout) = layout, READONLY
  # layout::R{PlotLayout} = layout, READONLY

  # table pagination
  temperature_data::R{DataTable} = DataTable(data)   
  credit_data_pagination::DataTablePagination = DataTablePagination(rows_per_page=50)     
end



function plot_data()
  plot_collection = Vector{PlotData}()
  # isempty(ic_model.xfeature[]) || isempty(ic_model.yfeature[]) && return plot_collection
  

  # station = data |> @filter(_.STATION_NAME == "TORONTO CITY CENTRE") |> DataFrame
  # sort!(station, :LOCAL_DATE)
  # ta = TimeArray(station.LOCAL_DATE, station.MEAN_TEMPERATURE)
  # TimeSeries.rename!(ta, :MEAN_TEMPERATURE)

  # # check for stationarity - because of the assumption
  # temp = DataFrames.select(station, :LOCAL_DATE, :MEAN_TEMPERATURE)
  # temp_arr = Core.Array(temp[:, 2])

  # check = ffill(temp_arr)
  # check = Core.Array{Float64}(check)

  # # sum(ismissing.(check))
  # stl_meanTemp = SeasonalTrendLoess.stl(check, 365)

  # dispplay in panel, 4 rows
  # p1 = Plots.Plot(ta[:MEAN_TEMPERATURE], label = "", ylabel = "Observed")
  # p2 = Plots.plot(stl_meanTemp.trend, label = "", ylabel = "Trend")
  # p3 = Plots.plot(stl_meanTemp.seasonal, label = "", ylabel = "Season")
  # p4 = Plots.plot(stl_meanTemp.remainder, label = "", ylabel = "Remainder")

  # subplot = Plots.plot(p1,p2, p3, p4, layout = (4,1), title = ["Seasonal Decompisition - Toronto - City Centre" "" "" ""])
  # subplot
  # p1
  # push!(plot_collection, pd("Random 1"))

  plot_collection
  plotdata = [pd("Random 1"),  pd("Random 2"),  pd("Random 3"),  pd("Random 4")]
  
end


function ui(model::seriesModel)
  # model.temperature_plot_data[] = plot_data()
  # model.layout = ""
  page(
    model, class="container", title="Ontario Weather Dashboard", head_content=Genie.Assets.favicon_support(),

    prepend = style(
    """
    tr:nth-child(even) {
      background: #F8F8F8 !important;
    }

    .modebar {
      display: none!important;
    }

    .st-module {
      background-color: #FFF;
      border-radius: 2px;
      box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.04);
    }

    .stipple-core .st-module > h5,
    .stipple-core .st-module > h6 {
      border-bottom: 0px !important;
    }
    """
    ),

    [
      heading("Ontario Weather Dashboard")

      # row([
        # expansionitem(expandseparator = true, icon = "tune", label = "Filters", hidebottomspace = true,
                      # class="col-12", style="padding: 4px;", [
          # row([
          #   # TODO: make dropdown
          #   # Html.div(class="col-12 col-sm-12 col-md-6 col-lg-6 col-xl-6", style="padding: 4px;", [
          #   #   select(:filter_regions, options = :regions, multiple = true, clearable = true,
          #   #     filled = true, label = "Regions", displayvalue = Dashboard.ALL_REGIONS, usechips = true,
          #   #     rules="[val => val && val.length > 0 || 'Please select at least one region']",
          #   #     hidebottomspace = true)
          #   # ])
  
          #   Html.div(class="col-6 col-sm-6 col-md-3 col-lg-3 col-xl-3", style="padding: 4px;", [
          #     textfield("Start date", :filter_startdate, clearable = true, filled = true, [
          #       icon(name = "event", class = "cursor-pointer", style = "height: 100%;", [
          #         popup_proxy(cover = true, transitionshow = "scale", transitionhide = "scale", [
          #           datepicker(:filter_startdate, mask = "YYYY-MM-DD", navmaxyearmonth = "$(Dates.year(now()))/$(Dates.month(now()))")
          #         ])
          #       ])
          #     ])
          #   ])
  
          #   Html.div(class="col-6 col-sm-6 col-md-3 col-lg-3 col-xl-3", style="padding: 4px;", [
          #     textfield("End date", :filter_enddate, clearable = true, filled = true, [
          #       icon(name = "event", class = "cursor-pointer", style = "height: 100%", [
          #         popup_proxy(ref = "qDateProxy", cover = true, transitionshow = "scale", transitionhide="scale", [
          #           datepicker(:filter_enddate, mask = "YYYY-MM-DD", navmaxyearmonth = "$(Dates.year(now()))/$(Dates.month(now()))")
          #         ])
          #       ])
          #     ])
          #   ])
          # ])
        # ])
      # ])
  
      # row([
      #   cell(class="st-module", [
      #     h6("Number of clusters")
      #     slider( 1:1:20,
      #             @data(:no_of_clusters);
      #             label=true)
      #   ])
      #   cell(class="st-module", [
      #     h6("Number of iterations")
      #     slider( 10:10:200,
      #             @data(:no_of_iterations);
      #             label=true)
      #   ])

      #   cell(class="st-module", [
      #     h6("X feature")
      #     Stipple.select(:xfeature; options=:features)
      #   ])

      #   cell(class="st-module", [
      #     h6("Y feature")
      #     Stipple.select(:yfeature; options=:features)
      #   ])s
      # ])
      h4("Decomposition time series using LOESS")
      row([
        cell(class="st-module", [
          h5("Observed")
          StipplePlotly.plot(:plot_1, layout= :layoutTest, config = "{ displayLogo:false }")
        ])
        cell(class="st-module", [
          h5("Remainder")
          StipplePlotly.plot(:plot_4, layout= :layoutTest, config = "{ displayLogo:false }")
        ])
      ])
      row([
        cell(class="st-module", [
          h5("Trend")
          StipplePlotly.plot(:plot_2, layout= :layoutTest, config = "{ displayLogo:false }")
        ])
        cell(class="st-module", [
          h5("Seasonal")
          StipplePlotly.plot(:plot_3, layout= :layoutTest, config = "{ displayLogo:false }")
        ])
      ])

      row([
        cell(class="st-module", [
          h4("Ontario Weather data")
          table(:temperature_data; pagination=:credit_data_pagination, dense=true, flat=true, style="height: 350px;")
        ])
      ])
    ]
  )
end

route("/") do
  seriesModel |> init |> ui |> html
end

up(9000; async = true, server = Stipple.bootstrap())
