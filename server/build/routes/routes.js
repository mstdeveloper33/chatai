"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const hello_router_1 = __importDefault(require("./hello_router"));
const gemini_router_1 = __importDefault(require("./gemini_router"));
const router = (0, express_1.Router)();
router.use("/hello", hello_router_1.default);
router.use("/generate_response", gemini_router_1.default);
exports.default = router;
