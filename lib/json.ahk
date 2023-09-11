

class Json {
    __New(indent:="    ",newLine:="`r`n") { ;default indent: 4 spaces. default newline: crlf
        this.ind := indent
        this.nl := newLine
    }

    getIndents(num) {
        indents := ""
        Loop num
            indents .= this.ind
        Return indents
    }


    objToJson(obj,indNum:=0) {
        indNum++
        str := "" , array := true
        for k in obj {
            if (k == A_Index)
                continue
            array := false
            break
        }
        for a, b in obj
            str .= this.getIndents(indNum) . (array ? "" : "`"" . a . "`": ") 
                    . ((IsObject(b)) ? this.objToJson(b,indNum) : this.isNumber(b) ? b : ("`""  . StrReplace(b,"`"","\`"") "`"") . ", " . this.nl)
        str := RTrim(str, " ," . this.nl)
        return (array ? "[" . this.nl . str . this.nl . this.getIndents(indNum-1) . "]" : "{" . this.nl . str . this.nl . this.getIndents(indNum-1) "}")
    }

    jsonToObj(jsonStr) {
        SC := ComObject("ScriptControl") 
        SC.Language := "JScript"
        
        jsCode :="
        (
        function arrangeForAhkTraversing(obj) {
            if(obj instanceof Array) {
                for(var i=0 ; i<obj.length ; ++i)
                    obj[i] = arrangeForAhkTraversing(obj[i]) ;
                return ['array',obj] ;
            } else if(obj instanceof Object) {
                var keys = [], values = [] ;
                for(var key in obj) {
                    keys.push(key) ;
                    values.push(arrangeForAhkTraversing(obj[key])) ;
                }
                return ['object',[keys,values]] ;
            } else
                return [typeof obj,obj] ;
        }
        )"
        SC.ExecuteStatement(jsCode "; obj=" jsonStr)
        return this.convertJScriptObjToAhkObj( SC.Eval("arrangeForAhkTraversing(obj)") )
    }

    convertJScriptObjToAhkObj(jsObj) {
        if(jsObj[0]=="object") {
            obj := {}, keys := jsObj[1][0], values := jsObj[1][1]
            loop keys.length
                obj[keys[A_INDEX-1]] := this.convertJScriptObjToAhkObj( values[A_INDEX-1] )
            return obj
        } else if(jsObj[0]=="array") {
            array := []
            loop jsObj[1].length
                array.insert(this.convertJScriptObjToAhkObj( jsObj[1][A_INDEX-1] ))
            return array
        } else
            return jsObj[1]
    }

    isNumber(Num) {
        if Num is number
            return true
        else
            return false
    }
}
jsonStr := "
(
{
    "id": "chatcmpl-7uRTO5ffXIUGUxns4n2w8q5LlTEbV",
    "object": "chat.completion",
    "created": 1693686330,
    "model": "gpt-3.5-turbo-0613",
    "choices": [
      {
        "index": 0,
        "message": {
          "role": "assistant",
          "content": "The OpenAI mission is to ensure that artificial general intelligence (AGI) benefits all of humanity. AGI refers to highly autonomous systems that outperform humans at most economically valuable work. OpenAI aims to build safe and beneficial AGI directly or to aid others in achieving this outcome. OpenAI commits to using any influence it obtains over AGI's deployment to ensure it is used for the benefit of everyone, avoiding uses that harm humanity or unduly concentrate power. Additionally, OpenAI seeks to actively cooperate with other research and policy institutions, aiming to create a global community working together to address AGI's challenges."
        },
        "finish_reason": "stop"
      }
    ],
    "usage": {
      "prompt_tokens": 14,
      "completion_tokens": 123,
      "total_tokens": 137
    }
  }
)"  
msgbox(Json().jsonToObj(jsonStr).choices[0].message.content)