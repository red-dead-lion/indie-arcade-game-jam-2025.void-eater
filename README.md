# Void Arena

This is my first game made in Godot. Originally it was intended to be released for the indie arcade game jam 2025, however due to a combination of a house move, immigration to another country, and caring for my partner who was undergoing treatment for her cancer at the time, development was delayed and I was not able to meet the deadline!

But despite all the hardship however, it was fun to work on in particular this game was an interesting look into the ENet implemetation used in godot.

As always, feel free to use the code however you wish, and a web build is availiable on on my itch.io page :)

<img width="440" height="440" alt="image" src="https://github.com/user-attachments/assets/cde1b819-de33-468d-830a-7364aa5a944c" /> <img width="440" height="440" alt="image" src="https://github.com/user-attachments/assets/9ab8966f-e63d-4df2-b528-adbf976d25f6" /> 

## Manual

To beign a game, a player should start a host locally by selecting a port and a number of players needed to join

Players on you local network should be able to join without any issues - If the particular port is open and you have set up forwatding rules on your router, players can also connect externally.

The purpose of the game is knock enemies out of the arena, push enemies out and avoid leaving the arena at any cost!

To begin with the arena is fully encapsulated by walls. However a void will continously move around and remove rooms at random.

Crates will periodically drop into the arena conitainig several items. Use them to your advantage to get the upper hand :)

### Items

<img width="16" height="16" alt="dynamite" src="https://github.com/user-attachments/assets/9d11f5c2-7e4f-413e-afc8-ffc1ae28e52b" />
- Dynamite can be used to blow players away and also blow up tiles after a short delay

<img width="28" height="27" alt="ghost_mode" src="https://github.com/user-attachments/assets/3a6f8d1b-fc28-4361-9840-567a38136f35" />
- When you enter ghost mode, you can pass through tiles and are not subject to the normal rules of physics. You can still however push other players around!

<img width="16" height="16" alt="hookshot" src="https://github.com/user-attachments/assets/ee6d5e32-c49b-4a2d-8a79-1a9e0f55b80e" />
- Use the hookshot to get around the level rapidly and cross over large areas that have been destroyed safely

<img width="15" height="10" alt="revolver" src="https://github.com/user-attachments/assets/7884b1c5-973a-4759-aa13-4c929ae78bc8" />
- The revolver is a powerful gun with bullets that will bounce around the level. Be careful of recoil!

<img width="16" height="10" alt="uzi" src="https://github.com/user-attachments/assets/8c4f24f1-a3bb-4605-8899-cf4371230fea" />
- The uzi is a rapid fireing gun, the bullets do not bounce but shoot a constant stream of bullets at enemies
