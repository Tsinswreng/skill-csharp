#import "@preview/tsinswreng-auto-heading:0.1.0": auto-heading
#let H = auto-heading;
\-\-\-

name: tsinswreng-csharp

description: C\#代碼規範

\-\-\-

#H[類型別名][
	僅用于有csproj的項目,
	不用于腳本項目如csx(dotnet script)
	```cs
	global using i32 = int;
	global using str = string;
	global using obj = object;
	global using nil = object; // 專門用來表示null
	global using CT = CancellationToken;
	```

	全局變量:`const nil NIL = null`
]


#H[異步函數規範][
	- 約定 最後一個參數聲明爲`CT Ct`的爲異步函數、不需要加`Async`後綴
	- 異步函數不返回值時、返回值聲明爲`Task<nil>`、不用無泛型的Task
	- 異步函數實現(有方法體的即函數實現)一定要加`async`
	正確示例:
	```cs
	async Task<nil> WriteToFile(str FilePath, str Content, CT Ct){
		...
		return NIL;
	}
	```
]

#H[AOT][
	除非特殊說明、
	*!!!所有代碼必須兼容AOT!!!*
	- 禁止使用一切不兼容AOT的反射, Emit等
	- 禁止在表達式樹外使用匿名對象
	- 禁止使用dynamic
]


#H[流式懶加載][
	#H[可迭代聚合][
		如果代碼中有 `IEnumerable<>`或`IAsyncEnumerable<>`
		則默認是需要懶加載的。

		設計API旹優先接收`IAsyncEnumerable<>`。

		對于可迭代聚合、謹慎使用`.ToList()`或類似API 因爲這會把所有元素都載入內存!
		也不要自己foreach消費的時候自己開List積攢起來

		需要操作內部元素旹盡量使用`.Select`保持懶加載

		可迭代集合 只允許消費一遍!! 不允許多次消費！
	]
	#H[流][
		流亦同理、 `Stream` 默認需要懶加載、不能把全部數據都一次性載入內存、不能用MemoryStream接收
	]

	總結常用對象:
	- 流: `Stream`
	- 泛型集合: `IAsyncEnumerable<>`, `IEnumerable<>`
	- 文本讀寫: `TextReader`, `TextWriter`
]

#H[異步優先][
	設計API旹優先考慮異步版本 尤其是IO操作相關的。
	善用`Task<T>`和`IAsyncEnumerable<T>`
]


#H[註釋][
	- *修改代碼時禁止隨意刪除已有的註釋*
	- 新寫的代碼一定要多加註釋
	- 註釋要避免正確的廢話 不能只是把表面的流程和意思翻譯一遍

	類型(interface/class/struct/enum 等等)/函數/成員 及 函數內部的實現(子步驟/關鍵分支) 都要寫註釋!!!

]

#H[聲明與實現分離][
	當你需要調用已有代碼的API時、大部分情況下你只需要關注函數聲明
	不需要關心內部具體實現 *以節約token*。

	有兩種情況、一種是基于接口實現;
	另一種是基于`partial`關鍵字實現(類似于C語言的頭文件);

	#H[基于接口][
		優先閱讀接口中的代碼。通過依賴注入系統使用接口。通常不需要閱讀具體實現。
	]
	#H[基于partial][
		約定:
		- Xxx.Decl.cs 表示 這個文件是專放聲明的;
		- Xxx.Impl.cs 表示 這個文件是專放實現的;
		訪問Xxx中的API時 若有則優先閱讀`*.Decl.cs`！㕥節省token
	]
	#H[以下情況你需要關注具體實現][
		- 你正在負責這塊代碼的維護工作、而不是作爲調用API的第三方。
	]

]


#H[代碼架構規範][
	#H[總則][
		- 一個函數儘量不要超過50行, 若超過則考慮拆分
		- 函數不應接收過多參數, 如果參數過多就應考慮建立專門的DTO作參數或返回值。
		- 使用面向接口的面向對象編程, 用interface來做抽象而不是父類。
		- 僅用類繼承作爲代碼複用的手段, 不依賴類繼承機制來作抽象
		- 遵守SOLID原則, 遵守常見設計模式
			- 該用策略模式就用, 別if-else滿天飛
		- *考慮可維護性 可擴展性 可測試性*
		- 要考慮常見的可能的未來擴展點。當前寫法不能把未來擴展的路堵死
		- 注意代碼複用, 避免重複代碼。發現有能抽取複用邏輯時要抽取複用。
		- 禁止字符串硬編碼鍵名。禁止魔法字符串 魔法數字。 多用 nameof / 枚舉 / 自己實現枚舉
	]

	#H[可維護性 可擴展性 可測試性][
		#H[減少依賴面, 統一門面][
			要把散亂的、各自的依賴整合成集中的依賴(門面),
			然後按門面訪問。
			把*同一類依賴*收斂到一個統一、穩定、語義化的入口（門面/抽象）,
			調用方只依賴這個入口。
			將來換實現時,
			只改入口後面,
			呼叫方不變。

			#H[先看示例][
				錯誤示例
				```cs
				class Svc{
					void Login(){
						...
						Console.WriteLine("Logged in");
					}
					void Logout(){
						...
						Console.WriteLine("Logged out");
					}
					void RefreshToken(){
						...
						Console.WriteLine("Token Refreshed");
					}
				}
				```
				解析:
				他們都各自依賴了`Console.WriteLine`作爲日誌輸出。
				若將來需要更換輸出目標則需要逐個修改代碼,
				可維護性差。

				最小改動的、非最佳做法的正確示例:
				````cs
				class Svc{
					void Log(str Msg){
						Console.WriteLine(Msg);
					}
					void Login(){
						...
						Log("Logged in");
					}
					void Logout(){
						...
						Log("Logged out");
					}
					void RefreshToken(){
						...
						Log("Token Refreshed");
					}
				}
				````
				在此例中,
				他們只依賴共同的門面`Log`,
				減少了依賴面
				將來切換實現時,
				只需更改Log中的代碼。
			]

			#H[禁止散亂的 魔法字符串/魔法數字 等][
				常見出錯點:
				- 按鍵取值中硬編碼鍵名
				- UI代碼中硬編碼字體大小/顏色等
				- 硬編碼UI顯示的未i18n的字符串, 硬編碼業務異常信息
				對于快速開發中的臨時硬編碼的UI文本或業務異常信息,
				應放在`Todo.I18n()`中。
				`Todo.I18n()`由業務項目自行定義,
				如未提供,
				則應停下來請示用戶。

				錯誤示例:
				```cs
				Button.Content = "登錄";
				throw new Exception("登錄失敗");
				```
				正確示例:
				````cs
				Button.Content = Todo.I18n("登錄");
				throw new Exception(Todo.I18n("登錄失敗"));
				````
			]

			#H[禁止散亂的 對具體實現的依賴][
				見上文Log之例
			]

			常見的正確做法:
			- 把魔法值收斂到變量裏
			- 抽取統一的門面函數(代碼量少, 適合早期快速推進)
			- interface+依賴注入(最佳)
		]
		#H[減少不必要的操作系統/平臺依賴][
			一個項目通常會劃分出多個程序集。
			要確保核心程序集是平臺無關的,
			不應依賴特定操作平臺的API,
			不應依賴文件系統,
			不依賴數據庫

			#H[文件操作不依賴文件系統][
				常見做法:用 `IFileSystem` 接口
				```cs
				using System.IO.Abstractions;
				//來自第三方庫。接口來自 TestableIO.System.IO.Abstractions ;
				//默認實現來自 TestableIO.System.IO.Abstractions.Wrappers
				//若用戶未安裝則先請示用戶
				AddSingleton<IFileSystem, FileSystem>();
				```
			]

			#H[用「流」作爲文件的抽象而不使用路徑作爲文件的抽象][
				錯誤示例:
				```cs
				Task<nil> ConvertPdfToPng(str InputPath, str OutputPath, CT Ct);
				await ConvertPdfToPng("myDoc.pdf", "myDoc.png");
				```

				正確示例:
				````cs
				Task<nil> ConvertPdfToPng(Stream Input, Stream Output, CT Ct);
				````
			]
		]

		#H[日誌門面][
			應在每個項目中定義一個`AppLog`作爲日誌門面
			```cs
			public class AppLog:DelegatingLogger {
				public static AppLog Inst => field??=new AppLog();
			}
			```
			其中`DelegatingLogger`是`ILogger`子類型,
			來自`Tsinswreng.CsLog`
			在程序入口處爲`AppLog.Inst`初始化。
			然後`AddSingleton<ILogger>(AppLog.Inst)`,
			方便依賴注入時就注入ILogger,
			不方便依賴注入時就直接調用全局可用的`AppLog.Inst`
		]

		#H[函數上下文][
			建議使用 `IFnCtx? Ctx`作實例方法API的第一個參數,
			增強可擴展性。
			來自`Tsinswreng.CsCtx`。
			靜態方法則不需。
		]
	]

	#H[基礎API與擴展方法][
		對于接口/類,等
		基礎/底層API應作爲其原始成員。
		且設計API時亦應優先考慮基礎API。

		滿足以下條件的API, 應考慮置于擴展中:
		- #[基于被擴展類型的API而得到,
				只是寫法上的簡化,
				並非能力上的擴展]
		- 作爲簡便寫法/高層封裝
		- 沒有多態/重寫的需求

		正確示例:
		```cs
		public class Tokenizer{
			public IEnumerable<Token> Tokenize(TextReader Reader){
				...
			}
		}

		public static class TokenizerExtn{
			public static IEnumerable<Token> Tokenize(this Tokenizer z, string Input){
				using TextReader reader = new StringReader(text);
				return z.Tokenize(reader);
			}
		}
		```

		錯誤示例:
		```cs
		public class Tokenizer{
			public IEnumerable<Token> Tokenize(TextReader Reader){
				...
			}

			public IEnumerable<Token> Tokenize(string Input){
				using TextReader reader = new StringReader(text);
				return this.Tokenize(reader);
			}
		}
		```
		解析:
		`TextReader`支持流式,
		不要求把所有輸入數據都加載在內存裏。
		`string`則要求整個字符串都在內存裏。
		因此可以輕鬆地無顧慮地把`string`適配成`TextReader`但反之則不行,
		會丟失流式能力,
		可能撐爆內存。
		因此`TextReader`適合作爲底層的API,
		但對于string爲主的場景, 接收`TextReader`的API調用起來不方便。
		因此 第二個 `string`版的API適合作爲擴展而非成員方法。

		上面的例子是拿class演示的。
		對于interface也同理,
		在 interface 中尤應如此。

		再說一遍,
		設計API時亦應優先考慮基礎API。
	]
]


#H[代碼風格][
	- 左大括號不換行
	- #[
			除`getter/setter`和lambda外、在類型中定義與實現的普通方法 禁止使用`=>`寫法。
			即使只有一行代碼也要寫成傳統的大括弧+return的函數體形式。
		]
	- #[if語句和循環 必須打大括號]

	#H[類型名命名規範][
		前綴命名:
		- IXxx: interface
		- EXxx: enum
		- PoXxx: 實體類, 對應數據庫中的表
		- SvcXxx: Xxx服務類
		- DaoXxx: 數據訪問層
		- CtrlrXxx: WebApi端點(Controller)
		- DtoXxx: 數據傳輸對像
		- ReqXxx: 請求/入參Dto
		- ResXxx: 響應/返回值Dto
		- KeysXxx: 鍵名枚舉(注意禁止到處硬編碼字符串鍵名, 須在統一的類中定義好再引用)
		- ViewXxx: 視圖
		- VmXxx: 視圖模型
		- ToolXxx: 工具
		- OptXxx: Options
		前綴可組合 如 ISvcXxx: Xxx服務接口

		後綴命名:
		- XxxExtn: 放擴展方法的類。 `extension(Xxx z){}`
		- IXxxExtn: `extension(IXxx z){}`
	]

	#H[變量名命名規範][
		- #[除函數中的局部變量外、所有標識符(包括函數參數)都用大駝峯! 首字母要大寫!
				```cs
				public class SvcUser{
					public Task<ResLogout> Logout(IFnCtx Ctx, Ct CT){
						var curTime = new UnixMs(); //僅函數中局部變量用小駝峯
						return ...;
					}

				}
				```
			]
		- private, protected, internal 變量, 應寫成 `MyPrivateVar`, 不用`_myPrivateVar`。
		- #[`public SomType _MyVar` 表示該字段爲寬鬆約定的 語義上的 非強制的 私有字段。
				個人傾向 靈活性優先, 傾向多使用public修飾。
				當一個字段 語義上爲私有但實際爲public時, 用下劃線+大駝峯如`_MyVar`
			]
	]

]

#H[其他事項][
	- 多打日誌
	- 少用元組。該自定義類型的就自定義
]


#H[漸近緟構法][
	緟構[被依賴得多]的符號時,
	優先做新版本而不是改老版本,
	然後再逐步遷移過去。
	
	假設有一個有問題的函數需要緟構,
	有20處引用了這個函數。
	```cs
	public (str FullPath, i64 CreatedTime, i64 ModifiedTime) GetFileInfo(str Path);
	```
	
	錯誤示例:
	````cs
	public FileInfo GetFileInfo(str Path);
	````
	
	正確示例:
	
	```cs
	public (str FullPath, i64 CreatedTime, i64 ModifiedTime) GetFileInfo(str Path);
	public FileInfo GetFileInfoV2(str Path);
	```
	
]
