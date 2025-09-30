// Assets/Editor/ShaderOpenWithVSCode.cs
#if UNITY_EDITOR
using System.Diagnostics;
using System.IO;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEngine;

public static class ShaderOpenWithVSCode
{
    // VS Code の起動コマンドを推測（PATH優先）。必要なら自分の環境に合わせて固定パスを設定してください。
    // 例: Windows 固定パス: @"C:\Users\<User>\AppData\Local\Programs\Microsoft VS Code\Code.exe"
    //     macOS 固定パス:  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    private static string ResolveVSCodeCommand()
    {
#if UNITY_EDITOR_WIN
        // 1) PATH の "code" を優先
        return @"C:\Users\k023g\AppData\Local\Programs\Microsoft VS Code\Code.exe"; // 入ってない場合は下のフォールバックに失敗することがあるので必要なら固定パス化
#elif UNITY_EDITOR_OSX
        return "code"; // mac も基本 "Shell Command: Install 'code' command in PATH" を実行しておく
#else
        return "code";
#endif
    }

    // VS Codeで開きたい拡張子
    private static readonly string[] _vscodeExts = new[]
    {
        ".shader", ".hlsl", ".cginc", ".compute", ".glslinc"
    };

    [OnOpenAsset]
    public static bool OnOpenAsset(int instanceID, int line)
    {
        var obj = EditorUtility.InstanceIDToObject(instanceID);
        if (obj == null) return false;

        var assetPath = AssetDatabase.GetAssetPath(obj);
        if (string.IsNullOrEmpty(assetPath)) return false;

        var ext = Path.GetExtension(assetPath).ToLowerInvariant();
        // Shader系だけ VS Code にリダイレクト
        if (System.Array.IndexOf(_vscodeExts, ext) < 0) return false;

        var fullPath = Path.GetFullPath(assetPath);

        // VS Code のコマンド解決
        var codeCmd = ResolveVSCodeCommand();

        // VS Code の -g オプションで 行番号 付きオープン
        // 行番号が 0 以下なら付けない
        var args = (line > 0)
            ? $"-g \"{fullPath}:{line}\""
            : $"\"{fullPath}\"";

        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = codeCmd,
                Arguments = args,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            Process.Start(psi);

            // ここで true を返すと Unity 既定のオープン処理はキャンセルされる（＝VS Code だけで開く）
            return true;
        }
        catch (System.Exception e)
        {
            UnityEngine.Debug.LogWarning($"VS Code 起動に失敗しました。PATH に 'code' を追加するか、スクリプト内で固定パスにしてください。\n{e}");
            return false; // 失敗時は既定のエディタにフォールバック
        }
    }
}
#endif
