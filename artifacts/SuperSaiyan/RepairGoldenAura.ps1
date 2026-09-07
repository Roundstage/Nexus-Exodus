$ErrorActionPreference = 'Stop'

$source_path = Join-Path $PSScriptRoot 'GoldenAura.pxc'
$output_path = Join-Path $PSScriptRoot 'GoldenAuraFixed.pxc'
$header_size = 37

$source_bytes = [System.IO.File]::ReadAllBytes($source_path)
$compressed_stream = [System.IO.MemoryStream]::new(
	$source_bytes,
	$header_size,
	$source_bytes.Length - $header_size
)
$decompressor = [System.IO.Compression.ZLibStream]::new(
	$compressed_stream,
	[System.IO.Compression.CompressionMode]::Decompress
)
$json_stream = [System.IO.MemoryStream]::new()
$decompressor.CopyTo($json_stream)
$decompressor.Dispose()

$project = [System.Text.Encoding]::UTF8.GetString($json_stream.ToArray()) | ConvertFrom-Json
if (-not $project.animator) {
	throw 'The project has no animator metadata.'
}

$project.animator | Add-Member -NotePropertyName frame_range_start -NotePropertyValue $null -Force
$project.animator | Add-Member -NotePropertyName frame_range_end -NotePropertyValue $null -Force
$project.timelines | Add-Member -NotePropertyName color -NotePropertyValue (-1) -Force
$project.timelines | Add-Member -NotePropertyName timeline_hide -NotePropertyValue $false -Force

$repaired_json = $project | ConvertTo-Json -Depth 100 -Compress
$repaired_bytes = [System.Text.Encoding]::UTF8.GetBytes($repaired_json)
$output_stream = [System.IO.MemoryStream]::new()
$output_stream.Write($source_bytes, 0, $header_size)
$compressor = [System.IO.Compression.ZLibStream]::new(
	$output_stream,
	[System.IO.Compression.CompressionLevel]::Optimal,
	$true
)
$compressor.Write($repaired_bytes, 0, $repaired_bytes.Length)
$compressor.Dispose()
[System.IO.File]::WriteAllBytes($output_path, $output_stream.ToArray())

Write-Output "Created $output_path"
