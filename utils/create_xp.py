import requests
from PIL import Image, ImageDraw, ImageFont
from sys import argv, exit
from io import BytesIO
from numerize import numerize

def pasteImage(img1, img2, pos):
    pix1 = img1.load()
    pix2 = img2.load()
    for x in range(img2.size[0]):
        for y in range(img2.size[1]):
            if x + pos[0] < img1.size[0] and y + pos[1] < img1.size[1] and y + pos[1] >= 0 and x + pos[0] > 0:
                pix1[x + pos[0], y + pos[1]] = pix2[x, y]

try:
    rank, level, xp, maxXp, totalXp, profilex, profiley, profilesizex, profilesizey, barposx, barposy, barx, bary = [int(i) for i in argv[1:14]]
    color = int(argv[14], 16)
    textcolor = int(argv[15], 16)
    name, profile, bg, result = argv[16:]
except:
    import traceback
    traceback.print_exc()
    print("Usage: {} <rank> <level> <xp> <totalXp> <levelMaxXp> <profilePicPosX> <profilePicPosY> <profilePicSizeX> <profilePicSizeY> <barPosX> <barPosY> <barSizeX> <barSizeY> <barhexcolor> <texthexcolor> <name> <profilePicPath> <bgPath> <resultPath>".format(argv[0]))
    exit(1)

bg = Image.open(bg)
profile = Image.open(BytesIO(requests.get(profile).content)).resize((profilesizex, profilesizey), Image.ANTIALIAS).convert("RGB")
textcolor = (textcolor >> 16, (textcolor >> 8) % (1 << 16), textcolor % (1 << 8))

bar = Image.new("RGB", bg.size, (0, 0, 0, 255))
pasteImage(bar, profile, (profilex, profiley))
pixels = bar.load()
for x in range(int(barx * (xp / maxXp)) + 1):
    for y in range(bary):
        pixels[barposx + x, barposy + y] = (color >> 16, (color >> 8) % (1 << 8), color % (1 << 8))
bar.paste(bg, (0, 0), bg)

draw = ImageDraw.Draw(bar)
xp = numerize.numerize(xp)
maxXp = numerize.numerize(maxXp)
totalXp = numerize.numerize(totalXp)

font = ImageFont.truetype("./ressources/arial.ttf", 20)
draw.text((profilex + profilesizex + 10, profiley + 10), "#{}  {}".format(rank, name), textcolor, font=font)
font = ImageFont.truetype("./ressources/arial.ttf", 15)
size, offset = font.font.getsize("Total: {}".format(totalXp))
size2, offset2 = font.font.getsize("{}/{}".format(xp, maxXp))

draw.text((barposx, barposy + bary + 3), "Level {}".format(level), textcolor, font=font)
draw.text((barposx + barx / 2 - size2[0] / 2, barposy + bary + 3), "{}/{}".format(xp, maxXp), textcolor, font=font)
draw.text((barposx + barx - size[0], barposy + bary + 3), "Total: {}".format(totalXp), textcolor, font=font)

bar.save(result)
print("Successfully created xp card")
