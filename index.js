exports.handler = async (event) => {
    console.log("Hello from Lambda!");
    return { statusCode: 200, body: "Hello World" };
};
