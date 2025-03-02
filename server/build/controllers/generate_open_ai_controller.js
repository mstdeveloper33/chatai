"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateOpenAiResponsesController = void 0;
const generateOpenAiResponsesController = (req, res) => {
    try {
        const reqBody = req.body;
        const prompt = reqBody["prompt"];
        res.json({ data: prompt });
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ data: error });
    }
};
exports.generateOpenAiResponsesController = generateOpenAiResponsesController;
