; curl https://api.openai.com/v1/chat/completions \
;  -H "Authorization: Bearer $OPENAI_API_KEY" \
;  -H "Content-Type: application/json" \
;  -d '{
;  "model": "gpt-3.5-turbo",
;  "messages": [{"role": "user", "content": "What is the OpenAI mission?"}] 
;  }'
basedir(f) {
    SplitPath(f,, &dir)
    return dir
}
; MsgBox(basedir(A_LineFile))
; MsgBox(FileRead(basedir(A_LineFile) . "\key"))
GPT_3_5_turbo()
class GPT_3_5_turbo {
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    class _API {
        
        _Authorization 
        {
            get {
                SplitPath(A_LineFile,, &dir)
                return "Bearer " . FileRead(dir . "\key")
            }
        }
        _ContentType :=  "application/json" 

    }
    
    _completionsAPI := "https://api.openai.com/v1/chat/completions"
    __New() {
       
        MsgBox(this.post())
    }

    ; The POST method that accepts headers as an object and uses messageBuilder for the body
    post(ask:="What is the OpenAI mission?") {
        req := this.whr
        ; Create the WinHTTP client
        req.Open("POST", this._completionsAPI)

        ; Add the headers from the object
        req.setRequestHeader("Authorization", GPT_3_5_turbo._API()._Authorization)
        req.setRequestHeader("Content-Type", GPT_3_5_turbo._API()._ContentType)

        ; Call messageBuilder for the body
        body := this.messageBuilder(ask)

        ; Send the request
        req.Send(body)

        ; Handle the response
        status := req.Status
        if (status >= 200 && status < 300) {
            A_Clipboard := req.ResponseText
            return req.ResponseText
        } else {
            throw "HTTP Error: " req.Status " " req.StatusText
        }
    }

    messageBuilder(ask:="What is the OpenAI mission?") {
        return '{"model": "gpt-3.5-turbo","messages": [{"role": "user", "content": "' . ask . '"}] }'
    }

}

