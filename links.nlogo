;; ok to delete.

ask Implementers [
ifelse any? other Implementers [have-info-same-team] [change-location]
ifelse any? IMDeployeds-here [have-info-same-team] [change-location]

end

to have-info-same-team
ifelse any? turtles-here with [holdinfo > 0] [checkarray9] [change-
location]
end

to checkarray9
ifelse any? other turtles-here with [array:item infoarray 9 > 0]
[array:set infoarray 9 1 set holdinfo 1 checkarray8][checkarray8]
end
