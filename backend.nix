# Majority of this code has been inspired by the official Open-WebUI nixpkgs
# For closer inspection, visit: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/op/open-webui/package.nix#L216

{ pkgs, pname, version, src, frontend }:

pkgs.python3Packages.buildPythonApplication rec {
    inherit pname version src;

    pyproject = true;

    build-system = with pkgs.python3Packages; [ hatchling ];

    # Not force-including the frontend build directory as frontend is managed by the frontend derivation in frontend.nix
    # I think this will need some improvements
    postPatch = ''
        substituteInPlace pyproject.toml \
            --replace-fail ', build = "open_webui/frontend"' ""
        cp -r ${frontend}/frontend ./webui
    '';

    env.HATCH_BUILD_NO_HOOKS = true;

    pythonRelaxDeps = true;

    pythonRemoveDeps = [
        "docker"
        "pytest"
        "pytest-docker"
    ];

    # These dependencies have been copied from https://github.com/open-webui/open-webui/blob/main/pyproject.toml
    # I could arrange them alphabetically but I'm too lazy for that.
    dependencies = with pkgs.python3Packages; [
        fastapi
        uvicorn
        pydantic
        python-multipart
        python-socketio
        python-jose
        passlib
        cryptography
        requests
        aiohttp
        async-timeout
        aiocache
        aiofiles
        starlette-compress
        httpx
        sqlalchemy
        alembic
        peewee
        peewee-migrate
        psycopg2-binary
        pgvector
        pymysql
        bcrypt
        pymongo
        redis
        boto3
        argon2-cffi
        apscheduler
        pycrdt
        restrictedpython
        loguru
        asgiref
        openai
        anthropic
        google-genai
        google-generativeai
        tiktoken
        langchain
        langchain-community
        fake-useragent
        chromadb
        pymilvus
        qdrant-client
        opensearch-py
        playwright
        elasticsearch
        pinecone-client
        transformers
        sentence-transformers
        accelerate
        colbert-ai
        einops
        ftfy
        pypdf
        fpdf2
        pymdown-extensions
        docx2txt
        python-pptx
        unstructured
        nltk
        markdown
        pypandoc
        pandas
        openpyxl
        pyxlsb
        xlrd
        validators
        psutil
        sentencepiece
        soundfile
        azure-ai-documentintelligence
        pillow
        opencv-python-headless
        rapidocr-onnxruntime
        rank-bm25
        onnxruntime
        faster-whisper
        pyjwt
        authlib
        black
        langfuse
        youtube-transcript-api
        pytube
        pydub
        ddgs
        google-api-python-client
        google-auth-httplib2
        google-auth-oauthlib
        googleapis-common-protos
        google-cloud-storage
        azure-identity
        azure-storage-blob
        ldap3
        firecrawl-py
        tencentcloud-sdk-python
        gcp-storage-emulator
        moto
        posthog
    ]
    ++ moto.optional-dependencies.s3 
    ++ pyjwt.optional-dependencies.crypto 
    ++ uvicorn.optional-dependencies.standard 
    ++ passlib.optional-dependencies.bcrypt;

    pythonImportsCheck = [ "open_webui" ];

     makeWrapperArgs = [
         ''--run "export DATA_DIR=\$HOME/.open-webui"''
         ''--run "export PORT=\"3000\""''
         ''--set FRONTEND_BUILD_DIR "${frontend}/frontend"''
     ];

     # makeWrapperArgs = [ 
     #     ''--run "export DATA_DIR=\$HOME/.open-webui"''
     #     ''--set PORT 3000''
     #     ''--set FRONTEND_BUILD_DIR "${frontend}/frontend"''
     # ];

    passthru = {
        tests = {
            inherit (pkgs.nixosTests) open-webui;
        };
        inherit frontend;
    };

    meta = {
        description = "User-friendly AI Interface (Supports Ollama, OpenAI API, ...)";
        homepage = "https://github.com/open-webui/open-webui";
        license = {
            fullName = "Open WebUI License";
            url = "https://github.com/open-webui/open-webui/tree/main?tab=License-1-ov-file#readme";
        };
        longDescription = ''
            Open WebUI is an extensible, feature-rich, and user-friendly self-hosted AI platform designed to operate entirely offline. It supports various LLM runners like Ollama and OpenAI-compatible APIs, with built-in inference engine for RAG, making it a powerful AI deployment solution.
        '';
        mainProgram = "open-webui";
        maintainers = with pkgs.lib.maintainers; [
            hiskingisdone
        ];
    };
}
