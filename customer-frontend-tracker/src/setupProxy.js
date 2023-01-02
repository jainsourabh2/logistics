const { createProxyMiddleware } = require('http-proxy-middleware');

/**
 * Setup backend-fetch proxy for localhost:8080.
 */
module.exports = function (app) {
    app.use(
        '/api/',
        createProxyMiddleware({
            target: 'https://bigtable-apis-q5cbfb3b6a-el.a.run.app'
            //target: 'http://35.200.173.88:8080',
            changeOrigin: false,
            secure: false,
            // pathRewrite: {
            //     '^/php': '/public/php'
            // }
        })
    );
};