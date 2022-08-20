const { PubSub, v1 } = require("@google-cloud/pubsub");
const pubSubClient = new PubSub();
const pubSubClient2 = new v1.PublisherClient();
const topicName = "vitaming";

const pubsubRepository = require("../repositories/pub-sub-repo");

const { publishMessage } = pubsubRepository;

module.exports = {
    orders: (req, res) => {
        console.log("Reached")
        return res.status(200).json({
            success: true,
            message: "Orders route confirmed :)",
        })
    },

    createOrders: async (req, res) => {
        console.log("Reached")
        let ordersObj = req.body;
        let messageId = await publishMessage(pubSubClient, topicName, ordersObj);
        return res.status(200).json({
            success: true,
            message: `Message ${messageId} published :)`
        })
    },

};