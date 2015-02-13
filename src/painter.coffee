
imageCache =
  data: {}
  get: (src) ->
    image = @data[src]
    if image?
      if image.complete and image.nativeWidth > 0
        return image
      else
        return undefined
    else
      image = new Image
      image.src = src

add = (a, b) ->
  x: a.x + b.x
  y: a.y + b.y

minus = (a, b) ->
  x: a.x - b.x
  y: a.y - b.y

renderText = (ctx, op) ->
  ctx.font = "#{op.size}px #{op.family}"
  ctx.textAlign = op.textAlign
  ctx.textBaseline = op.textBaseline
  ctx.fillStyle = op.fillStyle
  ctx.fillText op.text, 0, 0

renderRect = (ctx, op) ->
  dx = -(op.w / 2)
  dy = -(op.h / 2)
  if op.kind is 'clear'
    ctx.clearRect dx, dy, op.w, op.h
  else if ctx.fillStyle?
    ctx.fillStyle = op.fillStyle
    ctx.fillRect dx, dy, op.w, op.h
  else if ctx.strokeStyle?
    ctx.strokeStyle = op.strokeStyle
    ctx.strokeRect dx, dy, op.w, op.h

renderLine = (ctx, op) ->
  ctx.beginPath()
  ctx.lineTo op.x, op.y
  ctx.strokeStyle = op.color or 'black'
  ctx.stroke()

renderBezier = (ctx, op) ->
  ctx.beginPath()
  if op.between.length is 1
    a = op.between[0]
    ctx.quadraticCurveTo a.x, a.y, op.x, op.y
  else if op.between.length is 2
    a = op.between[0]
    b = op.between[1]
    ctx.bezierCurveTo a.x, a.y, b.x, b.y, op.x, op.y
  else
    throw new Error 'bezier takes 1 or 2 points'
  if op.strokeStyle?
    ctx.strokeStyle = op.strokeStyle
    ctx.stroke()
  if op.fillStyle?
    ctx.fillStyle = op.fillStyle
    ctx.fill()

renderArc = (ctx, op) ->
  ctx.beginPath()
  ctx.arc 0, 0, op.r, op.startAngle, op.endAngle, op.anti
  if op.fillStyle?
    ctx.fillStyle = op.fillStyle
    ctx.fill()
  if op.strokeStyle?
    ctx.strokeStyle = op.strokeStyle
    ctx.stroke()

renderAlpha = (ctx, op) ->
  ctx.globalAlpha = op.alpha

renderRotate = (ctx, op) ->
  angle = op.angle * Math.PI / 180
  ctx.rotate angle

renderTranslate = (ctx, op) ->
  ctx.translate op.x, op.y

renderTransform = (ctx, op) ->
  ctx.transform x[0], y[0], x[1], y[1], x[2], y[2]

renderImage = (ctx, op) ->
  image = imageCache.get op.src
  dx = op.x - (op.w / 2)
  dy = op.y - (op.h / 2)
  if image?
    if op.source?
      s = op.source
      sx = s.x - (s.w / 2)
      sy = s.y - (s.h / 2)
      ctx.drawImage image, sx, sy, s.w, w.h, dx, dy, op.w, op.h
    else
      ctx.drawImage image, dx, dy, op.w, op.h
  else
    ctx.fillStyle = '#eee'
    ctx.fillRect dx, dw, op.w, op.h

exports.paint = (operations, node) ->

  ctx = node.getContext('2d')
  ctx.clearRect 0, 0, node.width, node.height
  shiftX = Math.round (node.width / 2)
  shiftY = Math.round (node.height / 2)

  operations.forEach (op) ->
    ctx.save()
    ctx.translate op.base.x, op.base.y
    switch op.type
      when 'text'       then renderText ctx, op
      when 'line'       then renderLine ctx, op
      when 'bezier'     then renderBezier ctx, op
      when 'rect'       then renderRect ctx, op
      when 'arc'        then renderArc  ctx, op
      when 'save'       then ctx.save()
      when 'restore'    then ctx.restore()
      when 'alpha'      then renderAlpha ctx, op
      when 'rotate'     then renderRotate ctx, op
      when 'translate'  then renderTranslate ctx, op
      when 'transform'  then renderTransform ctx, op
      when 'image'      then renderImage ctx, op
      else console.warn "#{op.type} not finished"
    ctx.restore()
