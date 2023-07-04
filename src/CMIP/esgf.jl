# import HTTP, JSON
# function request_esgf(url)
#   p = HTTP.get(url)
#   data = JSON.parse(String(p.body))
#   data["response"]["docs"]
# end
import Ipaper: gsub, grepl

function build_url(host, params)
  host * "?" * join([string(k) * "=" * string(v) for (k, v) in params], "&")
end

function filter_url(urls, url_type = ["OPENDAP", "HTTPServer"])
  inds = grepl.(urls, url_type[1]) |> findall
  if isempty(inds)
    inds = grepl.(urls, url_type[2]) |> findall
  end
  isempty(inds) ? "" : urls[inds[1]]
end

function tidy_docs(x::Dict)
  url_raw = filter_url(x["url"])

  url, _, url_type = split(url_raw, "|")
  url = gsub(url, ".html", "")
  
  (; 
    variable   = x["variable"][1], 
    source_id  = x["source_id"][1], 
    resolution = x["nominal_resolution"][1], 
    size       = x["size"]/1e6,
    version    = basename(dirname(url)), 
    host       = get_host(url),
    file       = basename(url), 
    url_type,
    url)
end

tidy_docs(docs::AbstractVector) = map(tidy_docs, docs) |> DataFrame


export build_url, filter_url, tidy_docs
# function get_key(x::Dict, key; default = "")
#   haskey(x, key) ? x[key] : default
# end
# function select_keys(x::Dict, keys::AbstractVector)
#   OrderedDict(key => x[key][1] for key in keys)
# end
# names = ["variable", "source_id", "nominal_resolution"]
# d = DataFrame(select_keys(x, names))
