using DataFrames
using DataFramesMeta
using CSV
using GLMakie
## 
df = CSV.read("statcast_2023.csv",DataFrame)
##

for n in names(df)
    println(n)
end

##
function filter_teams(df, team)
    subset = filter(row -> team in (row.home_team, row.away_team), df)
    return subset
end
##
mets = filter_teams(df,"NYM")
##
