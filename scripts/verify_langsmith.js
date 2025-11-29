const { RunTree } = require('langsmith');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

async function verifyLangSmith() {
    console.log("🔍 Verifying LangSmith Configuration...");
    console.log(`API Key: ${process.env.LANGCHAIN_API_KEY ? 'Set' : 'Missing'}`);
    console.log(`Project: ${process.env.LANGCHAIN_PROJECT}`);
    console.log(`Endpoint: ${process.env.LANGCHAIN_ENDPOINT}`);

    try {
        const pipeline = new RunTree({
            name: "Verification Run",
            run_type: "chain",
            inputs: { test: "true" },
            project_name: process.env.LANGCHAIN_PROJECT || "gemini-orchestrator"
        });

        console.log("1. Posting Run...");
        await pipeline.postRun();
        console.log(`✅ Run Posted. ID: ${pipeline.id}`);

        const child = await pipeline.createChild({
            name: "Child Step",
            run_type: "tool",
            inputs: { input: "test" }
        });
        await child.postRun();
        await child.end({ outputs: { output: "success" } });
        await child.patchRun();
        console.log("2. Child Run Patched.");

        await pipeline.end({ outputs: { result: "verified" } });
        await pipeline.patchRun();
        console.log("3. Root Run Patched.");

        console.log("\n🎉 Verification Complete. Check project '" + (process.env.LANGCHAIN_PROJECT || "gemini-orchestrator") + "' in LangSmith.");

    } catch (e) {
        console.error("❌ LangSmith Error:", e.message);
        if (e.response) {
            try {
                const text = await e.response.text();
                console.error("Response:", text);
            } catch (err) { }
        }
    }
}

verifyLangSmith();
