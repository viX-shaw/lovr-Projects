local request = require("luajit-request/luajit-request")

function lovr.load()
    --
    local response = request.send("https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg")
    for k, v in pairs(response) do
        print("Response contains - "..k)
    end
    print("Status"..response.code)
    image = lovr.data.newImage(lovr.data.newBlob(response.body))
    print(image:getDimensions())

    mat = lovr.graphics.newMaterial(lovr.graphics.newTexture(image))
end

function lovr.update()
    --
end

function lovr.draw()
    --
    lovr.graphics.plane(mat, 0, 0, -2, 1, 1)
end