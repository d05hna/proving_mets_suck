using DataFrames 
using CSV
using Glob 
using GLMakie
using Blink
using StatsBase

ps = reverse(glob("*_all.csv"))

df = DataFrame()
##
for p in ps
    d = CSV.read(p, DataFrame)
    if p == "2023_all.csv"
        d.Column1 .= 1
    end
    d = filter(row -> !ismissing(row.events) && row.events == "home_run", d)
    df = vcat(df, d)
end
##
for n in names(df)
    println(n)
end
##
df.ru_home = ifelse.(df.inning_topbot .== "Top", 0, 1)

df.adj_d = ifelse.(df.ru_home .== 0, -1 .* df.delta_home_win_exp, df.delta_home_win_exp)

grouped_df = combine(groupby(df, :batter), :adj_d => length => :total, :adj_d => mean => :avg_d)

grouped_df.who .= "Not Pete Alonso"
grouped_df[144, :who] = "Pete Alonso"
##
GLMakie.activate!()
theme = theme_dark()
theme.textcolor=:white
theme.fontsize= 17
theme.gridcolor=:blue
theme.gridalpga=0.7
set_theme!(theme)
##
d4this = grouped_df[grouped_df.total .> 25, :]

fig = Figure(figsize=(10,10))
ax = Axis(fig[1, 1])

scatter!(ax, d4this.total, d4this.avg_d,alpha=0.5,color=:lightskyblue1)

ah = lines!(ax, [mean(d4this.total),mean(d4this.total)],[minimum(d4this.avg_d)-0.05,maximum(d4this.avg_d)+0.05],linewidth=3,color=:gray,linestyle=:dashdot,label="Average Homers")
ad = lines!(ax, [20,maximum(d4this.total)+0.05],[mean(d4this.avg_d),mean(d4this.avg_d)],linewidth=3,color=:gray,linestyle=:dashdot,label="Average Bump in Win EXP ")
ax.limits=(20,210,0.05,0.25)

hidedecorations!(ax,label=false)
ax.xlabel = "Total Homers Hit"
ax.ylabel = "Average Win Expectancy Added"
peter = scatter!(ax,196,0.132163, color=:red,label="Pete Alonso")
Legend(fig[1,2],[peter],["Pete Alonso"])
ax.title = "Homers Hit vs How Much It Helped Since 2019"

save("HomersWinExp.png",fig,px_per_unit=5)
fig
