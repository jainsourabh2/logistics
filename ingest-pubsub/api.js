const express = require('express')
const {PubSub} = require('@google-cloud/pubsub');
const app = express()
const port = 3000
const projectId = 'on-prem-project-337210', // Your Google Cloud Platform project ID
const topicNameOrId = 'vitaming', // Name for the new topic to create
const subscriptionName = 'vitaming-subscription' // Name for the new subscription to create
const pubsub = new PubSub({projectId});


app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})