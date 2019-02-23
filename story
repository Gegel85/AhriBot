forest
actions
set_position
pos
forest
--end
smrw
icons
🕵 👤 🤷 👊
message
Just before jumping, you see a woman passing here.\nWhat do you do ?
questions
'Wait for her to go' 'Jump so she can't see you' 'Jump next to her' 'Jump on her'
actions
prepare_message ask send_message
title
🌲
--end
see_gem_forest_med_rep
questions
'Hang in the forest' 'Search for food' 'Search for people'
title
💎
color
FFFF00
message
You found a gem on the ground while going off the tree.\nWhat do you want to do ?
item
common gem
actions
prepare_message ask give send_message
icons
🌳 🍴 🙋
--end
hang_in_forest
icons
🌳 🍴 🙋
color
00FFFF
actions
prepare_message ask send_message
questions
'Hang in the forest' 'Search for food' 'Search for people'
message
You jump on the ground.\nWhat do you want to do now ?
title
Forest
--end
smrm
icons
🕵 👤 🤷 👊
title
🌲
questions
'Wait for him to go' 'Jump so he can't see you' 'Jump next to him' 'Jump on him'
actions
prepare_message ask send_message
message
Just before jumping, you see a man passing here.\nWhat do you do ?
--end
see_someone_forest_med_rep
warp
jump_then_see_med_rep see_before_jump_med_rep
warp_requirement
'random<=200'
actions
warp
--end
see_before_jump_med_rep
warp
smrlb smrlg smrm smrw smrg
warp_requirement
'random<100' 'random<200' 'random<575' 'random<950'
actions
warp
--end
jmrw
icons
👤 😐 🗣 👞
message
You jump off of the tree. When you turn back you see a woman staring at you. She is a bit surprised.\nWhat do you do ?
questions
'Run away' "Down't move" 'Walk toward her' 'Run to her'
actions
prepare_message ask send_message
title
🌲
--end
begin_mountain
title
⛰ Wake up ! ⛰
color
777777
icons
🌲 🏠 ⛰
questions
'Forest' 'City 'Stay here'
actions
prepare_message ask send_message
message
You wake up in the cave you slept in.\nWhere do you want to go next ?
--end
jump_then_see_med_rep
warp
jmrlb jmrlg jmrm jmrw jmrg
warp_requirement
'random<100' 'random<200' 'random<575' 'random<950'
actions
warp
--end
jmrg
icons
👤 😐 🗣 👞
message
You jump off of the tree. When you turn back you see a guard staring at you. He is ready to draw his sword.\nWhat do you do ?
questions
'Run away' "Down't move" 'Walk toward him' 'Run to him'
actions
prepare_message ask send_message
title
🌲
--end
smrlg
icons
🕵 👤 🤷 👊
title
🌲
questions
'Wait for her to go' 'Jump so she can't see you' 'Jump next to her' 'Jump on her'
actions
prepare_message ask send_message
message
Just before jumping, you see a little girl passing here.\nWhat do you do ?
--end
begin_city
title
🏠 Wake up ! 🏠
color
777777
actions
prepare_message ask send_message
questions
'Forest' 'Stay here' 'Mountain'
message
You wake up in the house you slept in.\nWhere do you want to go next ?
icons
🌲 🏠 ⛰
--end
begin_forest
icons
🌲 🏠 ⛰
message
You wake up on the tree you slept on.\nWhere do you want to go next ?
title
🌲 Wake up ! 🌲
color
777777
warp_requirement_1
'reputation<-1000' 'reputation<-200' 'reputation<=200' 'reputation<=1000' 'reputation>1000'
warps_1
'forest_really_low_rep_warp_pick' 'forest_low_rep_warp_pick' 'forest_med_rep_warp_pick' 'forest_high_rep_warp_pick' 'forest_really_high_rep_warp_pick'
actions
prepare_message ask send_message
questions
'Stay here' 'City' 'Mountain'
--end
jmrlb
icons
👤 😐 🗣 👞
color
00FF00
message
You jump off of the tree. When you turn back you see a little boy staring at you. He is really surprised.\nWhat do you do ?
questions
'Run away' "Down't move" 'Walk toward him' 'Run to him'
actions
prepare_message ask send_message
title
🌲
--end
smrlb
icons
🕵 👤 🤷 👊
message
Just before jumping, you see a little boy passing here.\nWhat do you do ?
questions
'Wait for him to go' 'Jump so he can't see you' 'Jump next to him' 'Jump on him'
actions
prepare_message ask send_message
title
🌲
--end
smrg
icons
🕵 👤 🤷 👊
message
Just before jumping, you see a guard passing here. He has a sword.\nWhat do you do ?
questions
'Wait for him to go' 'Jump so he can't see you' 'Jump next to him' 'Jump on him'
actions
prepare_message ask send_message
title
🌲
--end
begin
warp
"begin_forest" "begin_city" "begin_mountain"
warp_requirement
"current_location=='forest'" "current_location=='city'" "current_location=='mountain'"
actions
warp
--end
jmrlg
🌲
actions
questions
'Run away' "Down't move" 'Walk toward her' 'Run to her'
message
You jump off of the tree. When you turn back you see a little girl staring at you. She is really surprised.\nWhat do you do ?
move
Walk toward her
title
🌲
Run to her'
icons
👤 😐 🗣 👞
title
icons
👤 😐 🗣 👞
actions
prepare_message ask send_message
prepare_message ask send_message
message
--end
test
warp
"look_for_food_city" "look_for_people_city" "go_to_park"
warp_requirement
current_location=='city'
title
Just a test
actions
prepare_message feed send_message
message
{{current_location}}
--end
jmrm
🌲
actions
Run to him'
icons
message
You jump off of the tree. When you turn back you see a man staring at you. He is a bit surprised\nWhat do you do ?
move
Walk toward him
icons
👤 😐 🗣 👞
questions
'Run away' "Down't move" 'Walk toward him' 'Run to him'
👤 😐 🗣 👞
title
title
🌲
actions
prepare_message ask send_message
prepare_message ask send_message
message
--end
end
energy
1
title
End of the day 😴
message
You felt asleep in {{current_location}}
actions
prepare_message use_energy send_message end_day
--end
forest_med_rep_warp_pick
warp
see_gem_forest_med_rep see_someone_forest_med_rep hear_someone_forest_med_rep hang_in_forest
warp_requirement
'random==0' 'random<=10' 'random<=100' 'random<=1000'
actions
warp
--end
