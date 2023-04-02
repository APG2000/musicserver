
const express =require('express')
const cors = require("cors");
const bodyParser = require('body-parser');
const app=express()
const youtubesearchapi = require("youtube-search-api");
// parse application/json
const ytdl = require("ytdl-core");
app.use(cors());
// parse application/json
app.use(bodyParser.json());

app.get("/search/:query",(req,res)=>{
  
  var query=req.params.query.replace(":","")
  let videos = function() {
    return youtubesearchapi.GetListByKeyword(query)
  }
  let videosDATa=videos()
  videosDATa.then(function(result){
    for(let i =0;i<result.items.length;i++){
      result.items[i].thumbnail=result.items[i].thumbnail.thumbnails[0].url
    }
    res.json(result.items)
  })
  
})



app.get("/make/:id",async (req,res)=>{ // verifica se a musica esta na base de dados caso nao esta ele baixa do youtube e mete na BD

    try{

      var videoid=req.params.id.replace(":","")

      console.log("procurando por :-->",videoid)
      const info = await ytdl.getInfo("https://www.youtube.com/watch?v="+videoid);


      let format = ytdl.chooseFormat(info.formats, {filter: 'audioonly'});
      //console.log('Format found!', format);
      const heading=format.url


      res.send(heading);
    }catch (e){
      res.sendStatus(500)
    }
    

})


app.listen(5000,()=>{console.log("server started in port 5000")})
